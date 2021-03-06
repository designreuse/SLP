package com.kse.slp.modules.onlinestores.modules.outgoingarticles.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.SessionFactory;
import org.hibernate.criterion.Criterion;
import org.hibernate.criterion.LogicalExpression;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Restrictions;
import org.springframework.beans.factory.annotation.Autowired;



import org.springframework.stereotype.Repository;





import com.kse.slp.dao.BaseDao;
import com.kse.slp.modules.onlinestores.common.Constants;
import com.kse.slp.modules.onlinestores.modules.outgoingarticles.model.mOrders;
import com.kse.slp.modules.onlinestores.modules.shippingmanagement.model.mOrderDetail;
@Repository("mOrdersDAO")
@SuppressWarnings({"unchecked", "rawtypes"})
public class mOrdersDAOImpl extends BaseDao implements mOrdersDAO{
	@Autowired
    private SessionFactory sessionFactory;

    public void setSessionFactory(SessionFactory sessionFactory) {
        this.sessionFactory = sessionFactory;
    }
	@Override
	public int saveAnOrder(mOrders order) {
		try{
			begin();
			int id = 0;
			id = (int)getSession().save(order);
			commit();
			return id;
		} catch (HibernateException e){
			e.printStackTrace();
			rollback();
			close();
			return -1;
		}finally {
			flush();
			close();
		}
	}
	@Override
	public mOrders getAnOrderById(int id) {
		try{
			begin();
			Criteria criteria = getSession().createCriteria(mOrders.class);
			criteria.add(Restrictions.eq("O_ID", id));
			List<mOrders> o= criteria.list();
			commit();
			return o.get(0);
		} catch (HibernateException e){
			e.printStackTrace();
			rollback();
			close();
			return null;
		}finally {
			flush();
			close();
		}
	}
	@Override
	public List<mOrders> getList() {
		// TODO Auto-generated method stub
		try{
			begin();
			Criteria criteria = getSession().createCriteria(mOrders.class);
			criteria.add(Restrictions.ne("O_Status_Code",Constants.ORDER_STATUS_DELIVERIED ));
			List<mOrders> listOrders = criteria.list();
			commit();
			return listOrders;
		}catch(HibernateException e){
			e.printStackTrace();
			rollback();
			close();
			return null;
		}finally{
			flush();
			close();
		}
	}
	@Override
	public mOrders loadAnOrderbyOrderCode(String orderCode) {
		// TODO Auto-generated method stub
		try{
			begin();
			Criteria criteria = getSession().createCriteria(mOrders.class);
			criteria.add(Restrictions.eq("O_Code", orderCode));
			List<mOrders> o= criteria.list();
			commit();
			if(o.size()>0)
			return o.get(0);
			else return null;
		} catch (HibernateException e){
			e.printStackTrace();
			rollback();
			close();
			return null;
		}finally {
			flush();
			close();
		}
	}

	@Override
	public void updateAnOrder(mOrders order) {
		try {
	           begin();
	           getSession().update(order);
	           commit();
	        } catch (HibernateException e) {
	            e.printStackTrace();
	            rollback();
	            close();
	        } finally {
	            flush();
	            close();
	        }
		
	}
	
	@Override
	public List<mOrderDetail> getListOrderDetail() {
		// TODO Auto-generated method stub
		try {
			begin();
			String sql = "SELECT mo.O_Code, mo.O_DeliveryLat, mo.O_DeliveryLng ,mo.O_TimeEarly, mo.O_TimeLate, mo.O_DueDate, mc.C_Name"
					+ " FROM mOrders mo, mClients mc"
					+ " WHERE (mo.O_Status_Code='"+Constants.ORDER_STATUS_NOT_IN_ROUTE+
								"' or mo.O_Status_Code='"+Constants.ORDER_STATUS_ARRIVED_BUT_NOT_DELIVERIED+"') and mo.O_ClientCode=mc.C_Code"
					+ " ORDER BY mo.O_DueDate ASC";
			Query query = getSession().createQuery(sql);
			List<Object[]> query_result = query.list();
			List<mOrderDetail> lstOrderDetail = new ArrayList<mOrderDetail>();
			
			for(int i=0; i<query_result.size(); i++){
				mOrderDetail tmp = new mOrderDetail();
				tmp.setO_Code((String)query_result.get(i)[0]);
				tmp.setO_DeliveryLat((float)query_result.get(i)[1]);
				tmp.setO_DeliveryLng((float)query_result.get(i)[2]);
				tmp.setO_TimeEarly((String)query_result.get(i)[3]);
				tmp.setO_TimeLate((String)query_result.get(i)[4]);
				tmp.setO_DueDate((String)query_result.get(i)[5]);
				tmp.setC_Name((String)query_result.get(i)[6]);
				System.out.println(name()+"::getListOrderDetail--mOrderDetail["+i+"]"+tmp.toString());
				lstOrderDetail.add(tmp);
			}
			
	        commit();
	        
	        return lstOrderDetail;
	        
	    } catch (HibernateException e) {
	    	e.printStackTrace();
	        rollback();
	        close();
	        return null;
	    } finally {
	    	flush();
	        close();
	    }
	}
	
	public String name(){
		return "mOrdersDAOImpl";
	}
	@Override
	public List<String> getListDueDate() {
		// TODO Auto-generated method stub
		try{
			
			begin();
			String sql = "SELECT DISTINCT mo.O_DueDate"
					+ " FROM mOrders mo"
					+ "	WHERE mo.O_Status_Code='"+Constants.ORDER_STATUS_NOT_IN_ROUTE+"' "
							+ "OR mo.O_Status_Code='"+Constants.ORDER_STATUS_ARRIVED_BUT_NOT_DELIVERIED+"'"
					+ " ORDER BY mo.O_DueDate ASC";
			List<String> lstOrDate = getSession().createQuery(sql).list();
			//System.out.println(name()+"::getListDueDate--lstOrDate: "+lstOrDate.toString());
			commit();
			
			return lstOrDate;
			
		}catch(HibernateException e){
			e.printStackTrace();
			rollback();
			close();
			return null;
		}finally{
			flush();
			close();
		}
	}
	@Override
	public List<mOrders> getListOrderByDueDate(String DueDate) {
		// TODO Auto-generated method stub
		try{
			begin();
			Criteria criteria = getSession().createCriteria(mOrders.class);
			criteria.add(Restrictions.eq("O_DueDate", DueDate));
			
			Criterion status1 = Restrictions.eq("O_Status_Code", Constants.ORDER_STATUS_ARRIVED_BUT_NOT_DELIVERIED);
			Criterion status2 = Restrictions.eq("O_Status_Code", Constants.ORDER_STATUS_NOT_IN_ROUTE);
			
			LogicalExpression orExp = Restrictions.or(status1, status2);
			
			criteria.add(orExp);
			
			List<mOrders> o= criteria.list();
			commit();
//			for(int i=0; i<o.size(); i++){
//				System.out.println(name()+"::getListOrderByDueDate--"+o.get(i).toString());
//			}
			return o;
		} catch (HibernateException e){
			e.printStackTrace();
			rollback();
			close();
			return null;
		}finally {
			flush();
			close();
		}
	}
	@Override
	public void updateStatus(String order_Code,String status) {
		// TODO Auto-generated method stub
		try{
			begin();
			String hql = "UPDATE mOrders set O_Status_Code = :status "  + 
		             "WHERE O_Code = :order_Code";
			Query query = getSession().createQuery(hql);
			query.setParameter("status", status);
			query.setParameter("order_Code", order_Code);
			int result = query.executeUpdate();
			System.out.println(name()+"Rows affected: " + result);
			commit();
		}catch(HibernateException e){
			e.printStackTrace();
			rollback();
			close();
		}finally{
			flush();
			close();
		}
	}
}
