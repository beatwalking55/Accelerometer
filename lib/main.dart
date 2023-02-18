import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter/services.dart';

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
  int lapTime = 0, oldLapTime = 0, lapTimeLim = 0, nowTime = 0, interval = 0;
  double dAccelePre = 0, dAcceleNow = 0, gain = 0.8, hurdol = 3, bpm = 0;
  List<double> accele = [0, 0, 0];
  List<num> speed = [0,0,0];
  num speedX = 0.0, speedY = 0.0, speedZ = 0.0;
  num dSpeedPre = 0, dSpeedNow = 0;

  final stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        //一応ローパスしとく
        accele[2] = accele[1];
        accele[1] = accele[0];
        accele[0] = gain * pow((pow(event.x,2)+pow(event.y,2)+pow(event.z,2)),0.5) + (1 - gain) * accele[1];
        // accele[0] = pow((pow(event.x,2)+pow(event.y,2)+pow(event.z,2)),0.5).toDouble();
        //dAccelePre：加速度の傾き（現在のひとつ前(previous)),dyAcceleNow：現在のやつ(now)
        dAccelePre = accele[1] - accele[2];
        dAcceleNow = accele[0] - accele[1];

        // speedX += event.x;
        // speedY += event.y;
        // speedZ += event.z;
        // speed[2] = speed[1];
        // speed[1] = speed[0];
        // speed[0] = speedY;//pow((pow(speedX,2)+pow(speedY,2)+pow(speedZ,2)),0.5);
        // dSpeedPre = speed[1] - speed[2];
        // dSpeedNow = speed[0] - speed[1];


        //ストップウォッチ動かす（多分初回だけ）
        if (stopwatch.isRunning == false) {
          stopwatch.start();
        }

        nowTime = stopwatch.elapsedMilliseconds; //ストップウォッチ動かしてからの時間
        //加速度の帯域的な極大値見つける
        if (accele[1] > hurdol &&
            dAccelePre > 0 &&
            dAcceleNow < 0 &&
            nowTime > (lapTime + lapTimeLim)) {
          //条件は、1.加速度が基準より上、
          //2.局所的に極大値である、
          //3.前回の極大値をとった時刻からlapTimeLim[ms]以上経っていること
          //です！この条件を満たす時、lapTimeを更新します。
          oldLapTime = lapTime;
          lapTime = stopwatch.elapsedMilliseconds;
          interval = lapTime - oldLapTime;
          bpm = 60000 / interval; //nowTime[ms]で2歩なので、bpm=2/(nowTime/1000)*60
          HapticFeedback.mediumImpact();
        }

        //速度の帯域的な極大値見つける
        // if (speed[1] > hurdol &&
        //     dSpeedPre > 0 &&
        //     dSpeedNow < 0 &&
        //     nowTime > (lapTime + lapTimeLim)) {
        //   //条件は、1.速度が基準より上、
        //   //2.局所的に極大値である、
        //   //3.前回の極大値をとった時刻からlapTimeLim[ms]以上経っていること
        //   //です！この条件を満たす時、lapTimeを更新します。
        //   oldLapTime = lapTime;
        //   lapTime = stopwatch.elapsedMilliseconds;
        //   interval = lapTime - oldLapTime;
        //   bpm = 60000 / interval; //nowTime[ms]で2歩なので、bpm=2/(nowTime/1000)*60
        //   HapticFeedback.mediumImpact();
        // }
      });
    }); //get the sensor data and set then to the data types
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
                          "speed is : ",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            speed[0].toStringAsFixed(2), //trim the asis value to 2 digit after decimal point
                            style: const TextStyle(fontSize: 20.0)),
                      )
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "stopwatch is : ",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            nowTime.toStringAsFixed(2), //trim the asis value to 2 digit after decimal point
                            style: const TextStyle(fontSize: 20.0)),
                      )
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "interval is : ",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            interval.toStringAsFixed(2), //trim the asis value to 2 digit after decimal point
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
