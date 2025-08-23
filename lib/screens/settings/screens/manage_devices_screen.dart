import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/settings/devices_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class ManageDevicesScreen extends StatefulWidget {
  const ManageDevicesScreen({Key? key}) : super(key: key);

  @override
  State<ManageDevicesScreen> createState() => _ManageDevicesScreenState();
}

class _ManageDevicesScreenState extends State<ManageDevicesScreen> {
  List<DevicesModel> deviceList = [];

  bool isError = false;

  @override
  void initState() {
    super.initState();
    getDeviceList();
  }

  Future<void> getDeviceList() async {
    appStore.setLoading(true);
    await getDevices().then((value) {
      if (value.runtimeType == List<dynamic>) {
        deviceList = [];
      } else {
        value.keys.map((e) => value[e]).toList().forEach((element) {
          deviceList.add(DevicesModel.fromJson(element));
        });
      }

      setState(() {});
      appStore.setLoading(false);
    }).catchError((e) {
      toast(e.toString());
      isError = true;
      setState(() {});
      appStore.setLoading(false);
    });
  }

  Future<void> removeDevice({required String id}) async {
    Map request = {"device_id": id};

    deviceList..removeWhere((element) => element.deviceId == id);
    setState(() {});
    await deleteDevice(request).catchError(onError);
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        centerTitle: true,
        title: Text(language.manageDevices, style: boldTextStyle()),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  language.manageDeviceText,
                  style: secondaryTextStyle(),
                  textAlign: TextAlign.center,
                ),
                16.height,
                if (deviceList.isNotEmpty)
                  ListView.builder(
                    itemCount: deviceList.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      DevicesModel device = deviceList[index];

                      final dateString = device.loginTime.validate();
                      DateTime dateTime = DateTime.parse(dateString);
                      String formattedDate = DateFormat("dd/MM/yyyy, h:mm a").format(dateTime);

                      return Container(
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: search_edittext_color),
                          color: context.cardColor,
                          borderRadius: radius(),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (device.deviceId == appStore.loginDevice)
                                  Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: context.primaryColor.withAlpha(30)),
                                    child: Text(
                                      '${language.currentDevice}',
                                      style: secondaryTextStyle(color: context.primaryColor, size: 12),
                                    ),
                                    margin: EdgeInsets.only(bottom: 6),
                                  ),
                                Text('${language.model}: ' + device.deviceModel.validate(), style: primaryTextStyle()),
                                Text('${language.deviceId}: ' + device.deviceId.validate(), style: secondaryTextStyle()),
                                Text('${language.loginTime}: ' + formattedDate, style: secondaryTextStyle()),
                              ],
                            ),
                            if (device.deviceId != appStore.loginDevice)
                              Positioned(
                                right: 0,
                                child: InkWell(
                                  child: Image.asset(ic_power_off, color: Colors.white, height: 20, width: 20),
                                  onTap: () {
                                    showConfirmDialogCustom(
                                      context,
                                      title: '${language.areYouSureYouWantToLogOutFromThisDevice}',
                                      primaryColor: colorPrimary,
                                      negativeText: language.no,
                                      positiveText: language.yes,
                                      onAccept: (context) async {
                                        removeDevice(id: device.deviceId.validate()).then((value){
                                          toast(language.youHaveBeenLoggedOutFromThisDevice);
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          if (deviceList.isEmpty && !appStore.isLoading)
            NoDataWidget(
              imageWidget: noDataImage(),
              title: language.noData,
            ).center(),
          if (isError && !appStore.isLoading)
            NoDataWidget(
              imageWidget: noDataImage(),
              title: language.somethingWentWrong,
            ).center(),
          Observer(
            builder: (_) {
              return LoaderWidget().center().visible(appStore.isLoading);
            },
          ),
        ],
      ),
    );
  }
}
