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
  start:

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
  mtype receiver, party;
  EncMsg message, data;
  start:

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

    network ? msgId3 (party , data);

    (data.content2 == 0 && party?== agentI);
    
    statusI = ok; 
    endI:
    (statusB==ok && statusI==ok);
}

	ltl BEIDE_OK { (statusI@endI == ok && statusB@endB == ok) && (statusB@start != ok && statusI@start != ok)} ;
