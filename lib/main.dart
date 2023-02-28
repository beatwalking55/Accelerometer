import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Accelerator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int lapTime = 0, oldLapTime = 0, lapTimeLim = 100, nowTime = 0, oldTime = 0, interval = 0, counter = 0;
  double dGyroPre = 0, dGyroNow = 0, gain = 0.84, acceleHurdol = 3, bpm = 0;
  List<double> accele = [0];
  List<double> acceleFiltered = [0,0];
  List<int> intervals = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
  List<double> gyro = [0,0];

  @override
  void initState() {
    super.initState();
    
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        
        acceleFiltered[1] = acceleFiltered[0];
        accele[0] = pow((pow(event.x,2)+pow(event.y,2)),0.5).toDouble();

        //RCローパスフィルタ
        acceleFiltered[0] = gain*acceleFiltered[1] + (1-gain)*accele[0];
      });
    }); //get the sensor data and set then to the data types

    gyroscopeEvents.listen(
      (GyroscopeEvent event) {
        setState(() {
          gyro[1] = gyro[0];
          gyro[0] = event.z;

          oldTime = nowTime;
          nowTime = DateTime.now().millisecondsSinceEpoch; //ストップウォッチ動かしてからの時間
          // debugPrint((nowTime-oldTime).toString());
          //加速度の帯域的な極大値見つける
          if (gyro[0]*gyro[1] < 0  &&
              acceleFiltered[0]> acceleHurdol &&
              nowTime > (lapTime + lapTimeLim)) {
            HapticFeedback.mediumImpact();
            oldLapTime = lapTime;
            lapTime = DateTime.now().millisecondsSinceEpoch;
            intervals[counter] = lapTime - oldLapTime;
            counter ++;
            if (counter == intervals.length) {
              HapticFeedback.vibrate();
              setState(() {
                calcBPMFromIntervals();
                  counter = 0;
                debugPrint(bpm.toString());
              });
            }
            debugPrint(interval.toString());
          }
        });
      },
    );
  }

  void calcBPMFromIntervals(){
    double aveDul = (intervals.reduce((a, b) => a + b) -
        intervals.reduce(math.max) -
        intervals.reduce(math.min)) /
        (intervals.length - 2);
    bpm = 60.0 / (aveDul / 1000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Flutter Sensor Library"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Table(
                border: TableBorder.all(
                    width: 2.0,
                    color: Colors.blueAccent,
                    style: BorderStyle.solid),
                children: [
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "acceleFilterd is : ",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            acceleFiltered[0].toStringAsFixed(4), //trim the asis value to 2 digit after decimal point
                            style: const TextStyle(fontSize: 20.0)),
                      )
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "gyro is : ",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            gyro[0].toStringAsFixed(4), //trim the asis value to 2 digit after decimal point
                            style: const TextStyle(fontSize: 20.0)),
                      )
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "BPM is : ",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            bpm.toStringAsFixed(2), //trim the asis value to 2 digit after decimal point
                            style: const TextStyle(fontSize: 20.0)),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
