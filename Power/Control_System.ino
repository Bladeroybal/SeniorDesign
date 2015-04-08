const int pwmpin = 3;
const int voltpin = A0;
const int currpin = A1;
int duty_ratio = 100;
int previousduty = 80;
int P_Power = 4.5;

void setup(){
  pinMode(pwmpin, OUTPUT);
}

void loop(){
  int voltsensor = analogRead(voltpin);
  int currentsensor = analogRead(currpin);
  int Power = voltsensor*currentsensor;
  /*if the current power value is less than the previous
  power value and the duty_ratio was decreased*/
  if (Power < P_Power && duty_ratio < previousduty){
    previousduty = duty_ratio; 
    duty_ratio = duty_ratio + 10;
  }
  /*if the current power value is less than the previous
  power value and the duty_ratio was increased*/
  else if(Power < P_Power && duty_ratio > previousduty){
    previousduty = duty_ratio;
    duty_ratio = duty_ratio - 10;
  }
  /*if the current power value is greater than the previous
  power value and the duty_ratio was decreased*/
  else if(Power > P_Power && duty_ratio < previousduty){
    previousduty = duty_ratio;
    duty_ratio = duty_ratio - 10;
  }
  /*if the current power value is greater than the previous
  power value and the duty_ratio was increased*/
  else if(Power > P_Power && duty_ratio > previousduty){
    previousduty = duty_ratio;
    duty_ratio = duty_ratio + 10;
  }
  else if(Power = P_Power){
    previousduty = duty_ratio;
    duty_ratio = duty_ratio;
  }
  
  //assign power value to previous power variable
  P_Power = Power;
  
  analogWrite(pwmpin, duty_ratio);
 
  delay(100);
}
