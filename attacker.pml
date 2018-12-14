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
