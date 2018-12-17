/**
   Vordefinierte Nachrichtentypen für die Modellierung des Kommunikationsprotokolls
*/
mtype = {ok, err, msgId1, msgId2, msgId3, keyA, keyB, keyI, agentA, agentB, agentI, nonceA, nonceB, nonceI };

typedef EncMsg { mtype key, content1, content2};

chan network = [0] of {mtype, /* Nachrichten Id */
                       mtype, /* Empfänger */
                       EncMsg};

/* Globale Ghostvariablen */
mtype partyB, partyI;
mtype statusB = err;
mtype statusI = err; 

/* Agent Beate */
active proctype Beate() {
  /* local variables */
  mtype otherKey;      /* der öffentliche Schlüssel des anderen Kommunikationsteilnehmers */
  mtype otherNonce;    /* nonce, die wir von einem anderen Kommunikationsteilnehmer erhalten haben */
  EncMsg encMessage; /* die verschlüsselte Nachricht, die wir an den anderen Kommunikationsteilnehmer schicken wollen */
  EncMsg data;      /* die empfangene verschlüsselte Nachricht */

 startB:
  /* Beate will mit Ingo reden  */
  
  partyB   = agentI;
  otherKey = keyI; 

  /* Zusammenstellen der zu verschickenden Nachricht */
  
  encMessage.key = otherKey;
  encMessage.content1 = agentB;
  encMessage.content2 = nonceB;  

  /* Sende die erste Nachricht */
  
  network ! msgId1 (partyB, encMessage);

  /*
    Warte auf die Antwort. Hier wird Pattern Matching verwendet, so dass
    nur Nachrichten mit der Nachrichtennummer msgId2, die an Beate (agentB)
    geschickt wurden entgegengenommen werden. Solange keine passende Nachricht
    vorhanden ist, blockiert dieser Prozess an dieser Stelle. 
    Bei Empfang der Nachricht wird der Inhalt der Nachricht in die Variable data
    kopiert.
  */
  network ? (msgId2, agentB, data);

   /* 
     Wir überprüfen hier, ob der Inhalt der Nachricht dem Protokoll entspricht, d.h.,
     es wird nur dan fortgefahren, wenn der Schlüssel in der EncMsg dem Schlüssel von 
     Beate (keyB) entspricht und die enthaltene Nonce der entspricht, die Beate vorher 
     verschickt hatte.
   */

  (data.key == keyB) && (data.content1 == nonceB);

  /* Auslesen der Nonce von Ingo */
  
  otherNonce = data.content2;

  /* Vorbereiten der abschliessenden Nachricht des Protokols */  
  encMessage.key = otherKey;
  encMessage.content1 = otherNonce; 
  encMessage.content2 = 0;  /* in der abschliessenden Nachricht wird das Feld "content2" nicht verwendet,
                              wir setzen es hier einfach auf 0, um nicht zwei Nachrichtenarten als Records 
                              modellieren zu müssen. */

  
  /* Verschicken der Nachricht */
  network ! msgId3 (partyB, encMessage);

  
  /* setzen der Ghostvariablenvariable statusB auf ok, da wir am Ende sind und alle Nachrichten dem Protokoll entsprochen haben */
  
  statusB = ok;
  endB:
}

/*
message:  EncMsg
party:    mtype
nonce:    mtype
*/

active proctype Ingo() {
  mtype otherKey, otherNonce;
  mtype receiver;
  mtype party;
  EncMsg message, data;
  startI:

  //Receive Message
    network ? msgId1 (receiver, data);
    (receiver == agentI);
    otherNonce = data.content2;
    if
      :: otherNonce == nonceA -> otherKey = keyA; partyI = agentA;
      :: otherNonce == nonceB -> otherKey = keyB; partyI = agentB;
      :: otherNonce == nonceI -> otherKey = keyI; partyI = agentI;
    fi
    message.key = otherKey;
    message.content1 = otherNonce;
    message.content2 = nonceI;

    network ! msgId2, partyI, message;

    network ? msgId3 ( party, data);

    (data.content2 == 0 && party?== agentI);
    
    statusI = ok; 
    endI:
    (statusB==ok && statusI==ok);
}
  active proctype Attacker() {
  mtype msg, receipt;
  EncMsg data, captured;
  do
    :: network ? (msg, _, data) ->
       if /* Merken oder Verwerfen der empfangenen Nachricht */
         :: captured.key   = data.key;
            captured.content1 = data.content1;
            captured.content2 = data.content2;
         :: skip;
       fi;

    :: /* Wiederspielen einer empfangenen Nachricht oder Senden einer neuen Nachricht */
       if /* choose message type */
         :: msg = msgId1;
         :: msg = msgId2;
         :: msg = msgId3;
       fi;
       if /* Auswahl eines Empfängers (hier: Beate oder Ingo) */
         :: receipt = agentB;
         :: receipt = agentI;
       fi;
       if 
       ::  if /* Neue Nachricht zusammenstellen. Auswahl des Inhaltes für die erste Inhaltskomponente der Nachricht */
              :: data.content1 = agentA;
              :: data.content1 = agentB;  
              :: data.content1 = agentI;  
              :: data.content1 = nonceA;
            fi;     
            if /* Auswahl eines öffentlichen Schlüssels */
              :: data.key = keyA;
              :: data.key = keyB;
              :: data.key = keyI;
            fi;
            data.content2 = nonceA; /* Im Moment: Setzen der zweiten Inhaltskomponente auf den festen Wert nonceA */
       :: /* Wiederspielen der zuvor abgefangenen Nachricht */
          data.key       = captured.key;
          data.content1  = captured.content1;
          data.content2  = captured.content2;
       fi;
      network ! msg (receipt, data);
  od
}

	ltl BEIDE_OK { (statusI@endI == ok && statusB@endB == ok) && (statusB@startB != ok && statusI@startI != ok)} ;
  //ltl TEST {(statusB==ok && statusI== ok)}