//Enge Brücke im Dunkeln 
// Alle laufen unterschiedlich schnell
// Dora:	01 Minute
// Bernd: 	02 Minuten
// Karin: 	05 Minuten
// Thomas:	10 Minuten

#define PASSENGERS 4;

inline checkFinished (array, result) {
	int i; 
	bool result;
	for ( i in array) {
	if
	:: array[i] == false -> result = false; break;
	fi }
	result = true;
}


active proctype P() {
	bool finished;
	byte time= 0;
	bool otherSide[PASSENGERS];
	int i;
	for(i in otherSide) {
		otherside[i] = false;
	}

	

	do
		::(boolEpxr) && finished == false  -> (statement); checkFinished(otherSide, finished);
		::
		:: finished == true -> break;
	od

	

}
