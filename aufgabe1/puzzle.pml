//Enge Brücke im Dunkeln 
// Alle laufen unterschiedlich schnell
// Dora:	01 Minute
// Bernd: 	02 Minuten
// Karin: 	05 Minuten
// Thomas:	10 Minuten


#define PASSENGERS 4

#define HIGH 3
#define LOW 0

inline checkFinished (array, result) {
	int i; 
	bool result;
	for ( i in array) {
	if
	:: array[i] == false -> result = false; break;
	fi }
	result = true;
}
inline oneToTrue(array,time,flash){
	//select a random false value and set it false add time set flashoos to true
	int i;
	do
		select(i : LOW .. HIGH);
		if
			::array[i] == false -> goto exit;
		fi
	od
		
	exit:
	array[i] = true;
	time = time + times[i];
	
	

	flash = true;
}

inline twoToTrue(array,time,flash){
	//select two random values and set them to true add time set flashoos to true
	int i; 
	int j;
	do
		select(i : LOW .. HIGH);
		select(j : LOW .. HIGH);
		if
			::array[i] == false && array[j] == false-> goto exit;
		fi
	od
	exit:
	array[i] = true;
	array[j] = true;
	byte _time;
	if
		:: times[i] >= times[j] -> _time = times[i];
		:: times[j] > times[i] -> _time = times[j];

	fi
	time = time + _time;

	flash = true;
}

inline oneToFalse(array,time,flash){
	//select one value which is false set it to true set flashoos to false and add time

	int a;
	do
	:: select (a : LOW .. HIGH);
		if
			::array[a] == true -> goto exit;
		fi
	od
		
	exit:
	array[a] = false;
	time = time + times[a];
	
	

	flash = false;

}
inline twoToFalse(array,time,flash){
	//select two false values set them to true add time set flashoos to false 
	int i; 
	int j;
	do
		select(i : LOW .. HIGH);
		select(j : LOW .. HIGH);
		if
			::array[i] == true && array[j] == true-> goto exit;
		fi
	od
	exit:
	array[i] = false;
	array[j] = false;
	byte _time;
	if
		:: times[i] >= times[j] -> _time = times[i];
		:: times[j] > times[i] -> _time = times[j];

	fi
	time = time + _time;

	flash = false;

}

inline getCountTrue(array,count){
	int i;
	count = 0;
	for(i in array){
		if 
			::array[i] == true -> count = count +1;
		fi
	}
}

inline move(selector,array,time,flash,count, finished){
	if
	::selector == 1 -> oneToFalse(array,flash,time);
	::selector == 2 -> twoToFalse(array,flash,time);
	::selector == 3 -> oneToTrue(array,flash,time);
	::selector == 4 -> twoToTrue(array,flash,time);
	fi
	getCountTrue(array,count);
	checkFinished(array,finished);

}

active proctype P() {
	int times[PASSENGERS];
	times[0] = 1;
	times[1] = 2;
	times[2] = 5;
	times[3] = 10;
	bool finished = false;
	byte time= 0;
	bool otherSide[PASSENGERS];
	bool flashOOS = false;
	int i;
	for(i in otherSide) {
		otherSide[i] = false;
	}

	int countTrue = 0;
	
	do
		::countTrue > 0 &&flashOOS == false && finished == false  -> move(1,otherSide,time,flashOOS,countTrue,finished);
		::countTrue > 1 &&flashOOS == false && finished == false -> move(2,otherSide,time,flashOOS,countTrue,finished);
		::countTrue < PASSENGERS && flashOOS == true && finished == false ->move(3,otherSide,time,flashOOS,countTrue,finished);			
		::countTrue < PASSENGERS -1 &&flashOOS ==true && finished == false->move(4,otherSide,time,flashOOS,countTrue,finished);	
		:: countTrue == 4 -> finished = true; break;
	od

}