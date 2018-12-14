//Enge Brücke im Dunkeln 
// Alle laufen unterschiedlich schnell
// Dora:	01 Minute
// Bernd: 	02 Minuten
// Karin: 	05 Minuten
// Thomas:	10 Minuten


#define PASSENGERS 4;

#define HIGH 3
#define LOW 0

byte times[PASSENGERS];
times[0] = 1;
times[1] = 2;
times[2] = 5;
times[3] = 10;

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

	int i;
	do
		select(i : LOW .. HIGH);
		if
			::array[i] == true -> goto exit;
		fi
	od
		
	exit:
	array[i] = false;
	time = time + times[i];
	
	

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

inline move(select,array,time,flash,count){
	if
		::select == 1 -> oneToFalse(array,flash,time);
		::select == 2 -> twoToFalse(array,flash,time);
		::select == 3 -> oneToTrue(array,flash,time);
		::select == 4 -> twoToTrue(array,flash,time);
	fi
	getCountTrue(array,count);
	checkFinished(array,finished);

			
active proctype P() {
	bool finished = false;
	byte time= 0;
	bool otherSide[PASSENGERS];
	bool flashOOS = false;
	int i;
	for(i in otherSide) {
		otherside[i] = false;
	}

	int countTrue = 4;
	

		


	do
		::countTrue > 0 &&flashOOS == false && finished == false  -> move(1,otherSide,time,flashOOS,countTrue,finished);
		::countTrue > 1 &&flashOOS == false && finished == false -> move(2,otherSide,time,flashOOS,countTrue,finished);
		::countTrue < PASSENGERS && flashOOS == true && finished == false ->move(3,otherSide,time,flashOOS,countTrue,finished);			
		::countTrue < PASSENGERS -1 &&flashOOS ==true && finished == false->move(4,otherSide,time,flashOOS,countTrue,finished);	
		:: finished == true -> break;
	od

	

}
