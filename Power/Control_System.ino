const int pwmpin = 6;
const int voltpin = A0;
const int currpin = A1;
const int batvolt = A4;
int duty_ratio = 100;
int previousduty = 80;
float P_Power = 4.5;

void setup(){
  pinMode(pwmpin, OUTPUT);
}

void loop(){
  int voltsensor = analogRead(voltpin);
  float volt = voltsensor*(5.0/1023);
  int currentsensor = analogRead(currpin);
  float current = currentsensor*(5.0/1023);
  float Power = volt*current;
  
  int battery_volt = analogRead(batvolt);
  float battery = battery_volt*(5.0/1023);
  if (volt > battery){
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
  if (duty_ratio < 20){
    duty_ratio = 20;
  }
  if (duty_ratio > 250){
    duty_ratio = 250;
  }
  }
  else{
    analogWrite(pwmpin, 0);
  }
  //assign power value to previous power variable
  P_Power = Power;
  
  analogWrite(pwmpin, duty_ratio);
}
