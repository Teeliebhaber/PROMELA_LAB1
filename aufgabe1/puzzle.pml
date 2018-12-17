//Enge Brücke im Dunkeln 
// Alle laufen unterschiedlich schnell
// Dora:	01 Minute
// Bernd: 	02 Minuten
// Karin: 	05 Minuten
// Thomas:	10 Minuten


#define PASSENGERS 4

#define HIGH 3
#define LOW 0


byte time = 0;

byte time0 = 1;
byte time1 = 2;
byte time2 = 5;
byte time3 = 10;

bool p0 = false
bool p1 = false;
bool p2 = false;
bool p3 = false;

bool flash = false;

inline checkFinished (result) {
	result = p0 && p1 && p2 && p3;
}

inline setItoFalse(i){
	if
	:: i == 0 -> p0 = false;
	:: i == 1 -> p1 = false;
	:: i == 2 -> p2 = false;
	:: i == 3 -> p3 = false;
	fi
}

inline setItoTrue(i){
	if
	:: i == 0 -> p0 = true;
	:: i == 1 -> p1 = true;
	:: i == 2 -> p2 = true;
	:: i == 3 -> p3 = true;
	fi
}

inline getI(i,t){
	if
	:: i == 0 -> t = p0;
	:: i == 1 -> t = p1;
	:: i == 2 -> t = p2;
	:: i == 3 -> t = p3;
	fi
}

inline getTime(i,t){
	if
	:: i == 0 -> t = time0;
	:: i == 1 -> t = time1;
	:: i == 2 -> t = time2;
	:: i == 3 -> t = time3;
	fi
}


inline oneToTrue(){
	//select a random false value and set it true add time set flashoos to true

	do
		::select(i : LOW .. HIGH);
		getI(i,t);
		if
			:: t == false -> goto exit;
            :: t == true -> ;
		fi
	od
	
	exit:
	setItoTrue(i);
	getTime(i,_time);
	time = time + _time

	flash = true;
}

inline twoToTrue(){
	//select two random values and set them to true add time set flashoos to true

	do
		::select(i : LOW .. HIGH);
		select(j : LOW .. HIGH);
		getI(j,z);
		getI(i,t);
		if
			:: t == false && z == false && i != j -> goto exit;
            :: t == true || z == true  || i == j-> ;
		fi
	od
	exit:

	setItoTrue(i);
	setItoTrue(j);
	getTime(i,_time1);
	getTime(j,_time2);
	
	if
	:: _time1 > _time2 -> time = time + _time1;
	:: _time2 >= _time1 -> time = time + _time2;
	fi

	flash = true;
}

inline oneToFalse(){
	//select one value which is false set it to true set flashoos to false and add time

	do
		::select(i : LOW .. HIGH);
		getI(i,t);
		if
			:: t == true -> goto exit;
            :: t = false -> ;
		fi
	od
	
	exit:
	setItoFalse(i);
	getTime(i,_time);
	time = time + _time

	flash = false;

}
inline twoToFalse(){
	//select two false values set them to true add time set flashoos to false 

	do
		::select(i : LOW .. HIGH);
		select(j : LOW .. HIGH);
		getI(j,z);
		getI(i,t);
		if
			:: t == true && z == true -> goto exit;
            :: t == false || z == false -> ;
		fi
	od
	exit:
	
	setItoFalse(i);
	setItoFalse(j);
	getTime(i,_time1);
	getTime(j,_time2);
	
	if
	:: _time1 > _time2 -> time = time + _time1;
	:: _time2 >= _time1 -> time = time + _time2;
	fi

	flash = false;
}

inline getCountTrue(count){

	count = 0;
	for(i : LOW .. HIGH){
        getI(i,t);
		if
		::t == true -> count++;
        ::t == false -> count = count;
		fi
	}
}

inline move(selector, count, finished){
    printf("movement i got here \n");
	if
	::selector == 1 -> oneToFalse();
	::selector == 2 -> twoToFalse();
	::selector == 3 -> oneToTrue();
	::selector == 4 -> twoToTrue();
	fi
	getCountTrue(count);
	checkFinished(finished);
    if
    :: time > 245 -> finished = true ;
	:: time <= 245 -> ;
	fi
    //handle overflow by asserting time to be a non critical value
    assert(time < 245);
    
}

active proctype P() {

	bool finished = false;
	int i;
    int j;
    bool t;
    bool z;
    byte _time;
    byte _time1;
    byte _time2;

	p0 = 0;
	p1 = 0;
	p2 = 0;
	p3 = 0;
	
    printf("atleast i got here \n");
	int countTrue = 0;
	
	do
		::countTrue > 0 && flash == true && finished == false  -> move(1,countTrue,finished);
		//::countTrue > 1 && flash == true && finished == false -> move(2,countTrue,finished);
		//::countTrue < PASSENGERS && flash == false && finished == false ->move(3,countTrue,finished);			
		::countTrue < PASSENGERS -1 && flash == false && finished == false->move(4,countTrue,finished);	
		::finished == true -> finished = true; break;
	od
    
    printf("countTrue %d\n",countTrue)
    printf("time needed %d\n\n" ,time);
    assert(time > 17);
}
