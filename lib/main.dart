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
  int lapTime = 0, oldLapTime = 0, lapTimeLim = 150, nowTime = 0, oldTime = 0, interval = 0;
  double dAccelePre = 0, dAcceleNow = 0, gain = 0.84, hurdol = 10, bpm = 0;
  List<double> a = [1,	-5.0294,	10.6070,	-11.9993,	7.6755,	-2.6311,	0.3775];
  List<double> b = [0.0000024972,	0.000014983,	0.000037458,	0.000049944,	0.000037458,	0.000014983,	0.0000024972];
  List<double> accele = [0,0,0,0,0,0,0];
  List<double> acceleFiltered = [0,0,0,0,0,0,0];
  List<num> speed = [0,0,0];
  num speedX = 0.0, speedY = 0.0, speedZ = 0.0;
  num dSpeedPre = 0, dSpeedNow = 0;

  final stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        
        accele[6] = accele[5];
        accele[5] = accele[4];
        accele[4] = accele[3];
        accele[3] = accele[2];
        accele[2] = accele[1];
        accele[1] = accele[0];
        acceleFiltered[6] = acceleFiltered[5];
        acceleFiltered[5] = acceleFiltered[4];
        acceleFiltered[4] = acceleFiltered[3];
        acceleFiltered[3] = acceleFiltered[2];
        acceleFiltered[2] = acceleFiltered[1];
        acceleFiltered[1] = acceleFiltered[0];
        accele[0] = event.y;
        // accele[0] = pow((pow(event.x,2)+pow(event.y,2)+pow(event.z,2)),0.5).toDouble();

        //IIRローパスフィルタ
        // acceleFiltered[0] = b[0]*accele[0]+b[1]*accele[1]+b[2]*accele[2]+b[3]*accele[3]+b[4]*accele[4]+b[5]*accele[5]+b[6]*accele[6]
        //                   +a[1]*acceleFiltered[1]+a[2]*acceleFiltered[2]+a[3]*acceleFiltered[3]+a[4]*acceleFiltered[4]+a[5]*acceleFiltered[5]+a[6]*acceleFiltered[6];

        //移動平均フィルタ
        // acceleFiltered[0] = accele.reduce((a, b) => a + b);

        //RCローパスフィルタ
        acceleFiltered[0] = gain*acceleFiltered[1] + (1-gain)*accele[0];

        //dAccelePre：加速度の傾き（現在のひとつ前(previous)),dyAcceleNow：現在のやつ(now)
        dAccelePre = acceleFiltered[1] - acceleFiltered[2];
        dAcceleNow = acceleFiltered[0] - acceleFiltered[1];

        //ストップウォッチ動かす（多分初回だけ）
        if (stopwatch.isRunning == false) {
          stopwatch.start();
        }

        oldTime = nowTime;
        nowTime = stopwatch.elapsedMilliseconds; //ストップウォッチ動かしてからの時間
        // debugPrint((nowTime-oldTime).toString());
        //加速度の帯域的な極大値見つける
        if (acceleFiltered[1] > hurdol &&
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
          debugPrint(interval.toString());
          bpm = 60000 / interval; //nowTime[ms]で2歩なので、bpm=2/(nowTime/1000)*60
          HapticFeedback.mediumImpact();
        }
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
                          "acceleFiltered is : ",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            acceleFiltered[0].toStringAsFixed(2), //trim the asis value to 2 digit after decimal point
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
