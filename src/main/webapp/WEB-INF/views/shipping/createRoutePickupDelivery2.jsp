<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript" src="<c:url value="/assets/libs/inputDate/dist/js/moment.js" />"></script>
<script type="text/javascript" src="<c:url value="/assets/libs/inputDate/dist/js/bootstrap-datetimepicker.min.js" />"></script>
<script type="text/javascript" src="<c:url value="/assets/libs/bootstrap/dist/js/collapse.js" />"></script>


<div id="page-wrapper">
	
    <div class="row">
        <div class="col-lg-12 center">
            <h1 class="page-header">Lật một kế hoạch chuyển hàng</h1>
        </div>
        <!-- /.col-lg-12 -->
    </div>
    <!-- /.row -->
    
     <div class="row">
     	<div class="panel panel-default">
     	<div class="col-lg-8">
    	<div id="map" style="height:100%">
     		</div>
     	</div>
     	<div class="col-lg-4" id="panelRight">
     		<div class="table-responsive">
	        	<table class="table table-striped table-bordered table-hover" id="rightPanel" >
	        		<thead>
	            		<tr>
	                    	<th>Khách hàng</th>
	                        <th>Thời gian dự kiến </th>
	                        <th>Thời gian yêu cầu</th>
	                        
	                    </tr>
	                </thead>
	                
	                <tbody>
	                		
	                </tbody>
	           	</table>
	       	</div>
     	</div>
    	
     	<div class="panel-body">
     		
     		<div class="form-group col-lg-12" >
     			
     			<label class="control-label col-lg-1" >Chọn Shipper</label>
     			<div class="col-lg-2" >
     				<select class="form-control shipperselect" id="shipperselect" name="shipperselect" >
     					
     					<c:forEach items="${listShipper}" var="lShp">
                                     	<option value="${lShp.SHP_Code}">${lShp.SHP_Code}</option>
                        </c:forEach>
     				</select>
     			</div>
     			<label class="control-label col-lg-1" >Chọn thời gian bắt đầu</label>
     			<div class="col-lg-2"> 
     				<input class="form-control" name="dateTimeStart" id="dateTimeStart" />
     			</div>
     			
     			<button type="button" class="btn btn-primary active" title="Thay đổi thời gian bắt đầu chuyển hàng" onclick="makeRightPanel()">Thay đổi</button>
     			<button type="button" class="btn btn-danger active" title="Xóa route ứng với shipper này" onclick="resetRoute()">Reset</button>
     			<button type="button" class="btn  active" id="deletebutton" title="Chuyển sang chế độ xóa" onclick="changeButtonDeleteStateClickMarker()">Xóa</button>
     			
     		</div>
     		<div class="col-lg-9">
     		<div class="table-responsive">
	            		<table class="table table-striped table-bordered table-hover" id="listShipperRoute">
	            			<thead>
	            			<tr>
	                        	<th>Người chuyển hàng</th>
	                            <th>Các địa điểm</th>
	                            <th>Tổng quãng đường</th>
	                            <th>Tổng thời gian</th>
	                        </tr>
	                        </thead>
	                        <tbody>
	                        	<c:forEach items="${listShipper}" var="items">
	                        		<tr>
	                        			<td><c:out value="${items.SHP_Code}"/></td>
	                        			<td><c:out value=""/></td>
	                        			<td><c:out value=""/></td>
	                        			<td><c:out value=""/></td>
	                        		</tr>
	                        	</c:forEach>
	                        </tbody>
	            		</table>
	            	</div>
	         </div>
     	</div>
     	</div>
     </div>
     
     
     <button type="submit" class="btn btn-primary active" onclick="saveData()" >Save</button>
     <button type="button" class="btn btn-default" >Close</button>
 
</div>
<script>
var status=0;
var marker=[];
var markerShipper=[];
var map;
var route=[];
var routePath=[];
var distanceMatrix=[];
var routeLatLng=[];
var listInfoWindow=[];
var distanceMatrix=[];
var serviceDistance ;
var lOPD=JSON.parse('${listPDOrder}');
var lShipper=JSON.parse('${listShipperJson}');
var reqCount=0;
var resCount=0;
var xdWait=true;
function changeButtonDeleteStateClickMarker(){
	console.log("changeStateClickMarker ");
	console.log(status);
	status=parseInt(status)+1;
	status=status % 2;
	if(status==0) 
		$("#deletebutton").removeClass("btn-warning");
	else	
		$("#deletebutton").addClass("btn-warning");
}	
$('#dateTimeStart').datetimepicker({
	format: 'YYYY-MM-DD HH:mm'
});
function initColorShipper(){
	for(i=0;i<lShipper.length;i++){
		var p1;
		var p2;
		var p3;
		[p1,p2,p3]=randomColor(p1,p2,p3);
		lShipper[i].color="rgb("+p1+","+p2+","+p3+ ")";
		
		
	}
}
function saveData(){
	console.log('saveData');
	var data=modelDataToSave();
	$.ajax({ 
	    type:"POST", 
	    url:"${baseUrl}/ship/save-container-routes",
	    data: JSON.stringify(data),
	    contentType: "application/json; charset=utf-8",
	    dataType: "json",
	    //Stringified Json Object
	    success: function(response){
	        // Success Message Handler
	    }
    });
	
}
function getColorTimeCheck(early,late,x){
	
	var mEarly=	moment(early,"YYYY-MM-DD HH:mm");
	var mLate= moment(late,"YYYY-MM-DD HH:mm");
	var xDate=moment(x,"YYYY-MM-DD HH:mm");
	
	if (mLate.isBefore(xDate) ) return "rgb(255, 102, 0)";
	if (mEarly.isAfter(xDate)) return "rgb(0, 153, 51)";
}

 function modelDataToSave(){
	var routesData=[];
	var nRoute=0;
	for(var i=0;i<route.length;i++)
		if(route[i].length > 1){
		routesData[nRoute]={
			"shipperCode": null,
			"dateTimeStart": null,
			"orderList":null
		}
		console.log(lShipper[i].SHP_Code);
		routesData[nRoute].shipperCode=lShipper[i].SHP_Code;
		routesData[nRoute].dateTimeStart=$("#dateTimeStart").val();
		routesData[nRoute].orderList=[];
		for(var j=1;j<route[i].length;j++){
			routesData[nRoute].orderList.push({
				"orderCode": route[i][j].orderCode,
				"isPickup": route[i][j].isPickup
			})
		}
		nRoute++;
		
	}
	console.log(routesData);
	return routesData;
}
 
 function initMap(){
	var mapDiv = document.getElementById('map');
	map = new google.maps.Map(mapDiv, {
		center: {lat: 21.03, lng: 105.8},
		zoom: 12,
		mapTypeId: google.maps.MapTypeId.ROADMAP
    });
	initColorShipper();
	for(var i=0;i<lShipper.length;i++){
		var lat= lShipper[i].SHP_DepotLat;
		var lng= lShipper[i].SHP_DepotLng;
		 markerShipper[i]= new google.maps.Marker({
			position:{lat:lat , lng: lng},
			icon:"http://maps.google.com/mapfiles/ms/icons/truck.png"
			});
		 markerShipper[i].setMap(map);
		 marker.push(markerShipper[i]);
		 route[i]=[];
		 route[i][0]={
				 "orderCode":"",
				 "isPickup":0,
				 "marker": markerShipper[i]
		 };
		 routeLatLng[i]=[];
		 routeLatLng[i][0]={
				 lat:markerShipper[i].getPosition().lat(),
				 lng:markerShipper[i].getPosition().lng()
		 }
		 routePath[i] = new google.maps.Polyline({
				path: routeLatLng[i],
				strokeColor: 'gray',
			    strokeOpacity: 1.0,
			    strokeWeight: 5,
			});
		 routePath[i].setMap(map);
	}
	var setPointOrderList=makeSetMarker();
	viewAllOrder(setPointOrderList);
	serviceDistance = new google.maps.DistanceMatrixService;
}
function markerSelectOrder(orderCode,pickup,marker_id){
	console.log(orderCode+" "+pickup+" "+marker_id);
	var indexSelectBox=$("#shipperselect option:selected").index();
	if(status==0 ){
		route[indexSelectBox].push({
			"orderCode": orderCode,
			"isPickup": pickup,
			"marker" : marker[marker_id]
		});
		console.log(marker[marker_id]);
		console.log("This is possion"+marker[marker_id].getPosition().lat()+" "+marker[marker_id].getPosition().lng());
		routeLatLng[indexSelectBox].push({
			lat:marker[marker_id].getPosition().lat(),
			lng:marker[marker_id].getPosition().lng()
		});
		routePath[indexSelectBox].setMap(null);
		routePath[indexSelectBox] = new google.maps.Polyline({
			path: routeLatLng[indexSelectBox],
			strokeColor: lShipper[indexSelectBox].color,
		    strokeOpacity: 1.0,
		    strokeWeight: 5,
		});
		routePath[indexSelectBox].setMap(map);
		}
	updateDistance();
	
}
function makeSetMarker(){
	var setPointOrder=[];
	for(var i=0;i< lOPD.length ;i++){
		var cpilat=lOPD[i].OPD_PickupLat;
		var cpilng=lOPD[i].OPD_PickupLng;
		var cdelat=lOPD[i].OPD_DeliveryLat;
		var cdelng=lOPD[i].OPD_DeliveryLng;
		xd=false;
		xd2=false;
		
		for(var j=0;j<setPointOrder.length;j++){
			var lat=setPointOrder[j][0].point.lat;
			var lng=setPointOrder[j][0].point.lng;
			if( lat==cpilat && lng== cpilng) {
				setPointOrder[j].push({
					"orderCode": lOPD[i].OPD_Code,
					"isPickup": 1,
					"point":{
						lat: cpilat,
						lng: cpilng
					}
				});
				xd=true;
			} else if (lat==cdelat && lng== cdelng){
				setPointOrder[j].push({
					"orderCode": lOPD[i].OPD_Code,
					"isPickup": 0,
					"point":{
						lat: cdelat,
						lng: cdelng
					}
				});
				xd2=true;
			} ;
		}
		if(xd==false){
			setPointOrder.push([{
				"orderCode": lOPD[i].OPD_Code,
				"isPickup": 1,
				"point":{
					lat: cpilat,
					lng: cpilng
				}
			}]);
		}
		if(xd2==false){
			
			setPointOrder.push([{
				"orderCode": lOPD[i].OPD_Code,
				"isPickup": 0,
				"point":{
					lat: cdelat,
					lng: cdelng
				}
			}]);
		}
	}
	return setPointOrder;
}
function makeRightPanel(){
	$("table#rightPanel tbody").html("");
	var dateTime = $("#dateTimeStart").val();
	var dateTime= moment(dateTime,"YYYY-MM-DD HH:mm");
	var nShipper=lShipper.length;
	var str;
	for(var i=0;i<lShipper.length;i++ ){
		str=str+"<tr>";
		str+="<td colspan='3' align='center'style='color:"+ lShipper[i].color +"'>"+lShipper[i].SHP_Code+"</td>";
		str=str+"</tr>";
		for(var j=1;j<route[i].length;j++){
			var dt_tmp=dateTime;
			var index=marker.indexOf(route[i][j].marker);
			var indexOld=marker.indexOf(route[i][j-1].marker);
			var distance=distanceMatrix[indexOld][index];
			dt_tmp.add(distance.duration,"seconds");
			str+="<tr>";
			str+="<td>"+lOPD[parseInt((index-nShipper)/2)].OPD_ClientCode +"</td>"
			
			if((index-nShipper)%2==1){
				str+="<td style='color:"+getColorTimeCheck(lOPD[(parseInt((index-nShipper)/2))].OPD_EarlyDeliveryDateTime,lOPD[parseInt((index-nShipper)/2)].OPD_LateDeliveryDateTime,dt_tmp.year()+"/"+parseInt( dt_tmp.month()+1)+"/"+dt_tmp.date()+" "+dt_tmp.hours()+":"+ dt_tmp.minutes())+"'>"+dt_tmp.year()+"/"+parseInt( dt_tmp.months()+1)+"/"+dt_tmp.date()+" "+dt_tmp.hours()+":"+ dt_tmp.minutes()+"</td>";
				str+="<td>"+lOPD[(parseInt((index-nShipper)/2))].OPD_EarlyDeliveryDateTime+"-"+lOPD[parseInt((index-nShipper)/2)].OPD_LateDeliveryDateTime+"</td>";
			} else {
				str+="<td style='color:"+getColorTimeCheck(lOPD[(parseInt((index-nShipper)/2))].OPD_EarlyPickupDateTime,lOPD[parseInt((index-nShipper)/2)].OPD_LatePickupDateTime,dt_tmp.year()+"/"+parseInt( dt_tmp.month()+1)+"/"+dt_tmp.date()+" "+dt_tmp.hours()+":"+ dt_tmp.minutes())+"'>"+dt_tmp.year()+"/"+parseInt( dt_tmp.months()+1)+"/"+dt_tmp.date()+" "+dt_tmp.hours()+":"+ dt_tmp.minutes()+"</td>";
				str+="<td>"+lOPD[parseInt((index-nShipper)/2)].OPD_EarlyPickupDateTime+"-"+lOPD[parseInt((index-nShipper)/2)].OPD_LatePickupDateTime+"</td>";
			}
			str+="</tr>";
			//console.log(dt_tmp.year()+" "+dt_tmp.month()+" "+dt_tmp.date()+" "+dt_tmp.hours()+" "+ dt_tmp.minutes());
		}
	}
	$("table#rightPanel tbody").append(str);
	
}
function makeInfoWindowContent(marker_id,setPointOrder){
	console.log("makeInfoWindowContent"+marker_id);
	var str="";
	for(var i=0;i< setPointOrder.length;i++){
		str+='<input type="checkbox" onclick="markerSelectOrder(\''+setPointOrder[i].orderCode  +'\','+setPointOrder[i].isPickup+','+marker_id +')">';
		if(setPointOrder[i].isPickup==1)
			str+=setPointOrder[i].orderCode+" Pickup";
		else str+=setPointOrder[i].orderCode+" Delivery";
		str+="</input><br>"
	}
	return str;
}
function viewAllOrder(setPointOrder){
	for(i=0;i<setPointOrder.length;i++){
		marker_tmp=new google.maps.Marker({
			position:{lat: setPointOrder[i][0].point.lat, lng: setPointOrder[i][0].point.lng},
			});
		marker.push(marker_tmp);
		if(setPointOrder[i].length>1){
			console.log("viewAllOrder"+marker.length);
			listInfoWindow[marker.length]=new google.maps.InfoWindow({
			    content: makeInfoWindowContent(marker.length-1,setPointOrder[i])
			  });
		}
		marker_tmp.infoWindow=listInfoWindow[marker.length];
		marker_tmp.setMap(map);
		if(setPointOrder[i][0].isPickup==0 ){
			marker_tmp.setIcon("https://www.google.com/mapfiles/marker_green.png");
		}
		//marker_tmp.predious=null;
		console.log(setPointOrder[i]+" "+i+ " "+marker[marker.length]);
		marker_tmp.setPointOrder=setPointOrder[i];
		marker_tmp.addListener('click',function(){
			if(this.setPointOrder.length>1){
				this.infoWindow.open(map,this);
			}else{
			var indexSelectBox=$("#shipperselect option:selected").index();
			
			if(status==0 ){
			route[indexSelectBox].push({
				"orderCode": this.setPointOrder[0].orderCode,
				"isPickup": this.setPointOrder[0].isPickup,
				"marker" : this
			});
			routeLatLng[indexSelectBox].push({
				lat:this.getPosition().lat(),
				lng:this.getPosition().lng()
			});
			routePath[indexSelectBox].setMap(null);
			routePath[indexSelectBox] = new google.maps.Polyline({
				path: routeLatLng[indexSelectBox],
				strokeColor: lShipper[indexSelectBox].color,
			    strokeOpacity: 1.0,
			    strokeWeight: 5,
			});
			routePath[indexSelectBox].setMap(map);
			} /* else if(status==1 && route[indexSelectBox].indexOf(this) !=-1) {
				var indexInRoute=route[indexSelectBox].indexOf(this);
				route[indexSelectBox].splice(indexInRoute,1);
				routeLatLng[indexSelectBox].splice(indexInRoute,1);
				routePath[indexSelectBox].setMap(null);
				routePath[indexSelectBox] = new google.maps.Polyline({
					path: routeLatLng[indexSelectBox],
					strokeColor: lShipper[indexSelectBox].color,
				    strokeOpacity: 1.0,
				    strokeWeight: 5,
				});
				routePath[indexSelectBox].setMap(map);
			} */
			updateDistance();
			
			
			}
		});
		
		/* marker_tmp2=new google.maps.Marker({
			position:{lat: lOPD[i].OPD_DeliveryLat, lng: lOPD[i].OPD_DeliveryLng},
			icon:"https://www.google.com/mapfiles/marker_green.png"
			});
		marker_tmp2.setMap(map);
		marker_tmp2.predious=marker_tmp;
		marker_tmp2.addListener('click',function(){
			if(setPointOrder[i].lenght>1){
				
			}else{
			var indexSelectBox=$("#shipperselect option:selected").index();
			if(status==0 &&  route[indexSelectBox].indexOf(this) ==-1){
			if(route[indexSelectBox].indexOf(this.predious)==-1) {
				alert("Điểm đầu chưa được chọn!!");
			}else{
			route[indexSelectBox].push(this);
			routeLatLng[indexSelectBox].push({
				lat:this.getPosition().lat(),
				lng:this.getPosition().lng()
			});
			routePath[indexSelectBox].setMap(null);
			routePath[indexSelectBox] = new google.maps.Polyline({
				path: routeLatLng[indexSelectBox],
				strokeColor: lShipper[indexSelectBox].color,
			    strokeOpacity: 1.0,
			    strokeWeight: 5,
			});
			routePath[indexSelectBox].setMap(map);
			}}  else if(status==1 && route[indexSelectBox].indexOf(this) !=-1){
				var indexInRoute=route[indexSelectBox].indexOf(this);
				route[indexSelectBox].splice(indexInRoute,1);
				routeLatLng[indexSelectBox].splice(indexInRoute,1);
				routePath[indexSelectBox].setMap(null);
				routePath[indexSelectBox] = new google.maps.Polyline({
					path: routeLatLng[indexSelectBox],
					strokeColor: lShipper[indexSelectBox].color,
				    strokeOpacity: 1.0,
				    strokeWeight: 5,
				});
				routePath[indexSelectBox].setMap(map);
				
			} 
			updateDistance();
			
			saveData();
			}
		}); 
		marker.push(marker_tmp2); */
	}
}
function randomColor( p1,p2,p2){
	
	p1=Math.floor((Math.random() * 85));
	p2=Math.floor((Math.random() * 255));
	p3=Math.floor((Math.random() * 255));
	return [p1,p2,p3];
}
function resetRoute(){
	var indexSelectBox=$("#shipperselect option:selected").index();
	route[indexSelectBox]=[route[indexSelectBox][0]];
	routeLatLng[indexSelectBox]=[routeLatLng[indexSelectBox][0]];
	routePath[indexSelectBox].setMap(null);
	updateDistance();
	makeRightPanel();
	
}

function getDistanceGoogleMap(p1,p2,indexOld,index){
	serviceDistance.getDistanceMatrix(
			  {
			    origins: [p1],
			    destinations: [p2],
			    travelMode: 'DRIVING',
			    unitSystem: google.maps.UnitSystem.METRIC,
			    avoidHighways: false,
			    avoidTolls: false,
			  }, function(response,status){
				  if(status!=='OK'){
					  alert("Fail!");
					  return null;
				  }else{
					  
					  distanceMatrix[indexOld][index]={
							  duration: response.rows[0].elements[0].duration.value,
							  distance: response.rows[0].elements[0].distance.value
					  }
					  
					  resCount++;
				  }
			  });
	
}

function updateDistance(){

	var indexSelectBox=$("#shipperselect option:selected").index();
	
	reqCount=0;
	resCount=0;
	for(i=1;i<routeLatLng[indexSelectBox].length;i++){
		var index=marker.indexOf(route[indexSelectBox][i].marker);
		var indexOld=marker.indexOf(route[indexSelectBox][i-1].marker);
		
		if(distanceMatrix[indexOld]== undefined ) distanceMatrix[indexOld]=[];
		if(distanceMatrix[indexOld][index]== undefined ){
			reqCount++;
			getDistanceGoogleMap(routeLatLng[indexSelectBox][i-1],routeLatLng[indexSelectBox][i],indexOld,index);
		}
		
	}
	
	xd=true;
	wait();
	
}

function wait(){
	if(resCount!=reqCount){
		setTimeout(wait, 200);
	} else if(xdWait==true){
		pushDistance();
		makeRightPanel();
		xdWaint=false;
	}
}
function pushDistance(){
	
	var indexSelectBox=$("#shipperselect option:selected").index();
	var distanceKm=0;
	var distanceTime=0;
	for(i=1;i<routeLatLng[indexSelectBox].length;i++){
		var index=marker.indexOf(route[indexSelectBox][i].marker);
		var indexOld=marker.indexOf(route[indexSelectBox][i-1].marker);
		distanceKm+=distanceMatrix[indexOld][index].distance;
		distanceTime+=distanceMatrix[indexOld][index].duration;
	}
	
	var cellsOfShipper=document.getElementById("listShipperRoute").rows[indexSelectBox+1].cells;
	cellsOfShipper[2].innerHTML=distanceKm;
	cellsOfShipper[3].innerHTML=moment.duration(distanceTime,'seconds').days() + "ngày "+ moment.duration(distanceTime,'seconds').hours()+" giờ "+moment.duration(distanceTime,'seconds').minutes()+"phút";
}
</script>
<script async defer
        src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDEXgYFE4flSYrNfeA7VKljWB_IhrDwxL4&callback=initMap">
</script>
<!-- /#page-wrapper -->