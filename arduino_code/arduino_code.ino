bool eStopOn = false;
int buttonReleased = 1;
int buttonState;
int lastButtonState = HIGH;

int ledPin = 4;
int buttonBin = 5;

double debounceTime = 0;
double debounceThreshold = 50;

void setup(){
    Serial.begin(9600);
    pinMode(ledPin,OUTPUT);
    pinMode(buttonBin,INPUT);
    
}


void loop(){
    buttonState = digitalRead(5);


    if(buttonState != lastButtonState){
        buttonReleased = !buttonReleased;

        if(buttonReleased){
            eStopOn = !eStopOn;
        }
    }

    lastButtonState = buttonState;

    if(eStopOn){
        digitalWrite(ledPin,1);
        Serial.print(1);
        Serial.write(13);
        Serial.write(10);
        
    }
    else{
        digitalWrite(ledPin,0);
        Serial.print(0);
        Serial.write(13);
        Serial.write(10);
    }
}
