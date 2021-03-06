package com.kse.slp.modules.onlinestores.modules.clientmanagment.controller.ac;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.kse.slp.modules.onlinestores.modules.clientmanagment.model.mClients;
import com.kse.slp.modules.onlinestores.modules.clientmanagment.service.mClientsService;
import com.kse.slp.modules.onlinestores.modules.clientmanagment.validation.mClientSearchTag;
import com.kse.slp.modules.onlinestores.modules.outgoingarticles.controller.mOrderController;
import com.kse.slp.modules.usermanagement.model.User;


@Controller
public class mClientAjaxController {
	private static final Logger log = Logger.getLogger(mClientAjaxController.class);
	@Autowired
	mClientsService clientsService;
	@ResponseBody @RequestMapping(value="/clientSearch-byPhone", method = RequestMethod.POST)
	public  List<mClientSearchTag> getTags(@RequestBody String tag_Json ,HttpSession session) {
		System.out.println(name()+" "+tag_Json);
		JSONParser parser = new JSONParser();
		JSONObject json;
		try {
			json = (JSONObject) parser.parse(tag_Json);
			String s= (String) json.get("inputString");
			List<mClients> lClients= clientsService.loadClientbyPhoneTag(s);
			List<mClientSearchTag> lCT= new ArrayList<mClientSearchTag>();
			for(int i=0;i<lClients.size();i++){
				lCT.add(new mClientSearchTag(lClients.get(i).getC_PhoneNumber(), lClients.get(i).getC_Name(), lClients.get(i).getC_Address()));
			}
			User u=(User) session.getAttribute("currentUser");
			log.info(u.getUsername()+" DONE");
			return lCT;
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			User u=(User) session.getAttribute("currentUser");
			log.info(u.getUsername()+" FAIL");
			return null;
		}
	}
	@ResponseBody @RequestMapping(value="/cm/save-A-Client", method = RequestMethod.POST)
	public  boolean saveAClient(@RequestBody String infoClient) {
		System.out.println(name()+" "+"saveAClient");
		JSONParser parser = new JSONParser();
		JSONObject json;
		try {
			json = (JSONObject) parser.parse(infoClient);
			String phone= (String) json.get("phone");
			String name= (String) json.get("name");
			String email= (String) json.get("email");
			String address= (String) json.get("address");
			String facebook= (String) json.get("facebook");
			clientsService.saveAClient(phone, name, address, facebook, email);
			return true;
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
	}
	public String name(){
		return "mClientAjaxController::";
	}
}
