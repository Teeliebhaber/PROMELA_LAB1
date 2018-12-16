/**
   Vordefinierte Nachrichtentypen für die Modellierung des Kommunikationsprotokolls
*/
mtype = {ok, err, msgId1, msgId2, msgId3, keyA, keyB, keyI, agentA, agentB, agentI, nonceA, nonceB, nonceI };

typedef EncMsg { mtype key, content1, content2};

chan network = [0] of {mtype, /* Nachrichten Id */
                       mtype, /* Empfänger */
                       EncMsg}; /*Die Nachricht*/

/* Globale Ghostvariablen */
mtype partyB, partyI;
mtype statusB = err;
mtype statusI = err; 

/*LTL */
ltl BEIDE_OK {statusB == ok && statusI == ok}
#define b_ok (statusB == ok)
#define i_ok (statusI == ok)

/* Agent Beate */
active proctype Beate() {
  /* local variables */
  
  mtype otherKey;      /* der öffentliche Schlüssel des anderen Kommunikationsteilnehmers */
  mtype otherNonce;    /* nonce, die wir von einem anderen Kommunikationsteilnehmer erhalten haben */
  EncMsg encMessage; /* die verschlüsselte Nachricht, die wir an den anderen Kommunikationsteilnehmer schicken wollen */
  EncMsg data;      /* die empfangene verschlüsselte Nachricht */


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
}

/*
message:  EncMsg
party:    mtype
nonce:    mtype
*/
inline determineSenderOfFirstMessage(message, party, nonce) {
    if
      ::message.content1 == agentA && message.content2 == nonceA-> //Message from Attacker
          party=agentA; 
          otherKey = keyA;
          nonce = nonceA;
          printf("Message from Attacker\n");

      ::message.content1 == agentB && message.content2 == nonceB -> //Message from Beate
          party = agentB; 
          otherKey = keyB;
          nonce = nonceB;
          printf("Message from Beate\n");

      ::message.content1 == agentI && message.content2 == nonceI -> //Message from Ingo
          party = agentI; 
          otherKey = keyI;
          nonce = nonceI;
          printf("Message from Ingo\n");
    fi
}

active proctype Ingo() {

  /*local variables*/
    mtype otherKey;
    mtype otherNonce;
    mtype messageId, receiver;
    EncMsg encMessage;
    EncMsg data;

  /*Receive "Chat Request from Beate".
    The format is the following:
    (key, to, enc)
    key:    Public Key of Receiver
    to:     Receiver
    enc:    Encrypted message
  */

    //Receive the message
    network ? messageId, receiver, data;
    //Assert
    (data.key == keyI);
    //Check which kind of messageId got received
    if
      :: messageId == msgId1 -> // New Conversation Invite
        determineSenderOfFirstMessage(data, partyI, otherNonce);

        encMessage.key = otherKey;
        encMessage.content1 = otherNonce;
        encMessage.content2 = nonceI;
        network ! msgId2 (partyI, encMessage);
    fi
    data.key = 0;
    data.content1 = 0;
    data.content2 = 0;
    network ? messageId, receiver, data;
    (messageId == msgId3 && receiver == agentI&&  data.content1 == nonceI && data.key == keyI);
    statusI=ok;
}
