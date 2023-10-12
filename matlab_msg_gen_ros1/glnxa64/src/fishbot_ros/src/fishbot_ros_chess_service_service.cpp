// Copyright 2019-2021 The MathWorks, Inc.
// Common copy functions for fishbot_ros/chess_serviceRequest
#include "boost/date_time.hpp"
#include "boost/shared_array.hpp"
#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable : 4244)
#pragma warning(disable : 4265)
#pragma warning(disable : 4458)
#pragma warning(disable : 4100)
#pragma warning(disable : 4127)
#pragma warning(disable : 4267)
#pragma warning(disable : 4068)
#pragma warning(disable : 4245)
#else
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpedantic"
#pragma GCC diagnostic ignored "-Wunused-local-typedefs"
#pragma GCC diagnostic ignored "-Wredundant-decls"
#pragma GCC diagnostic ignored "-Wnon-virtual-dtor"
#pragma GCC diagnostic ignored "-Wdelete-non-virtual-dtor"
#pragma GCC diagnostic ignored "-Wunused-parameter"
#pragma GCC diagnostic ignored "-Wunused-variable"
#pragma GCC diagnostic ignored "-Wshadow"
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#endif //_MSC_VER
#include "ros/ros.h"
#include "fishbot_ros/chess_service.h"
#include "visibility_control.h"
#include "ROSPubSubTemplates.hpp"
#include "ROSServiceTemplates.hpp"
class FISHBOT_ROS_EXPORT fishbot_ros_msg_chess_serviceRequest_common : public MATLABROSMsgInterface<fishbot_ros::chess_service::Request> {
  public:
    virtual ~fishbot_ros_msg_chess_serviceRequest_common(){}
    virtual void copy_from_struct(fishbot_ros::chess_service::Request* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    //----------------------------------------------------------------------------
    virtual MDArray_T get_arr(MDFactory_T& factory, const fishbot_ros::chess_service::Request* msg, MultiLibLoader loader, size_t size = 1);
};
  void fishbot_ros_msg_chess_serviceRequest_common::copy_from_struct(fishbot_ros::chess_service::Request* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //prev_move
        const matlab::data::CharArray prev_move_arr = arr["PrevMove"];
        msg->prev_move = prev_move_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'PrevMove' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'PrevMove' is wrong type; expected a string.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T fishbot_ros_msg_chess_serviceRequest_common::get_arr(MDFactory_T& factory, const fishbot_ros::chess_service::Request* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","PrevMove"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("fishbot_ros/chess_serviceRequest");
    // prev_move
    auto currentElement_prev_move = (msg + ctr)->prev_move;
    outArray[ctr]["PrevMove"] = factory.createCharArray(currentElement_prev_move);
    }
    return std::move(outArray);
  }
class FISHBOT_ROS_EXPORT fishbot_ros_msg_chess_serviceResponse_common : public MATLABROSMsgInterface<fishbot_ros::chess_service::Response> {
  public:
    virtual ~fishbot_ros_msg_chess_serviceResponse_common(){}
    virtual void copy_from_struct(fishbot_ros::chess_service::Response* msg, const matlab::data::Struct& arr, MultiLibLoader loader); 
    //----------------------------------------------------------------------------
    virtual MDArray_T get_arr(MDFactory_T& factory, const fishbot_ros::chess_service::Response* msg, MultiLibLoader loader, size_t size = 1);
};
  void fishbot_ros_msg_chess_serviceResponse_common::copy_from_struct(fishbot_ros::chess_service::Response* msg, const matlab::data::Struct& arr,
               MultiLibLoader loader) {
    try {
        //move
        const matlab::data::CharArray move_arr = arr["Move"];
        msg->move = move_arr.toAscii();
    } catch (matlab::data::InvalidFieldNameException&) {
        throw std::invalid_argument("Field 'Move' is missing.");
    } catch (matlab::Exception&) {
        throw std::invalid_argument("Field 'Move' is wrong type; expected a string.");
    }
  }
  //----------------------------------------------------------------------------
  MDArray_T fishbot_ros_msg_chess_serviceResponse_common::get_arr(MDFactory_T& factory, const fishbot_ros::chess_service::Response* msg,
       MultiLibLoader loader, size_t size) {
    auto outArray = factory.createStructArray({size,1},{"MessageType","Move"});
    for(size_t ctr = 0; ctr < size; ctr++){
    outArray[ctr]["MessageType"] = factory.createCharArray("fishbot_ros/chess_serviceResponse");
    // move
    auto currentElement_move = (msg + ctr)->move;
    outArray[ctr]["Move"] = factory.createCharArray(currentElement_move);
    }
    return std::move(outArray);
  } 
class FISHBOT_ROS_EXPORT fishbot_ros_chess_service_service : public ROSMsgElementInterfaceFactory {
  public:
    virtual ~fishbot_ros_chess_service_service(){}
    virtual std::shared_ptr<MATLABPublisherInterface> generatePublisherInterface(ElementType type);
    virtual std::shared_ptr<MATLABSubscriberInterface> generateSubscriberInterface(ElementType type);
    virtual std::shared_ptr<MATLABRosbagWriterInterface> generateRosbagWriterInterface(ElementType type);
    virtual std::shared_ptr<MATLABSvcServerInterface> generateSvcServerInterface();
    virtual std::shared_ptr<MATLABSvcClientInterface> generateSvcClientInterface();
};  
  std::shared_ptr<MATLABPublisherInterface> 
          fishbot_ros_chess_service_service::generatePublisherInterface(ElementType type){
    std::shared_ptr<MATLABPublisherInterface> ptr;
    if(type == eRequest){
        ptr = std::make_shared<ROSPublisherImpl<fishbot_ros::chess_service::Request,fishbot_ros_msg_chess_serviceRequest_common>>();
    }else if(type == eResponse){
        ptr = std::make_shared<ROSPublisherImpl<fishbot_ros::chess_service::Response,fishbot_ros_msg_chess_serviceResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
    return ptr;
  }
  std::shared_ptr<MATLABSubscriberInterface> 
          fishbot_ros_chess_service_service::generateSubscriberInterface(ElementType type){
    std::shared_ptr<MATLABSubscriberInterface> ptr;
    if(type == eRequest){
        ptr = std::make_shared<ROSSubscriberImpl<fishbot_ros::chess_service::Request,fishbot_ros::chess_service::Request::ConstPtr,fishbot_ros_msg_chess_serviceRequest_common>>();
    }else if(type == eResponse){
        ptr = std::make_shared<ROSSubscriberImpl<fishbot_ros::chess_service::Response,fishbot_ros::chess_service::Response::ConstPtr,fishbot_ros_msg_chess_serviceResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
    return ptr;
  }
  std::shared_ptr<MATLABSvcServerInterface> 
          fishbot_ros_chess_service_service::generateSvcServerInterface(){
    return std::make_shared<ROSSvcServerImpl<fishbot_ros::chess_service::Request,fishbot_ros::chess_service::Response,fishbot_ros_msg_chess_serviceRequest_common,fishbot_ros_msg_chess_serviceResponse_common>>();
  }
  std::shared_ptr<MATLABSvcClientInterface> 
          fishbot_ros_chess_service_service::generateSvcClientInterface(){
    return std::make_shared<ROSSvcClientImpl<fishbot_ros::chess_service,fishbot_ros::chess_service::Request,fishbot_ros::chess_service::Response,fishbot_ros_msg_chess_serviceRequest_common,fishbot_ros_msg_chess_serviceResponse_common>>();
  }
#include "ROSbagTemplates.hpp" 
  std::shared_ptr<MATLABRosbagWriterInterface> 
          fishbot_ros_chess_service_service::generateRosbagWriterInterface(ElementType type){
    std::shared_ptr<MATLABRosbagWriterInterface> ptr;
    if(type == eRequest){
        ptr = std::make_shared<ROSBagWriterImpl<fishbot_ros::chess_serviceRequest,fishbot_ros_msg_chess_serviceRequest_common>>();
    }else if(type == eResponse){
        ptr = std::make_shared<ROSBagWriterImpl<fishbot_ros::chess_serviceResponse,fishbot_ros_msg_chess_serviceResponse_common>>();
    }else{
        throw std::invalid_argument("Wrong input, Expected 'Request' or 'Response'");
    }
    return ptr;
  }
#include "register_macro.hpp"
// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
CLASS_LOADER_REGISTER_CLASS(fishbot_ros_msg_chess_serviceRequest_common, MATLABROSMsgInterface<fishbot_ros::chess_serviceRequest>)
CLASS_LOADER_REGISTER_CLASS(fishbot_ros_msg_chess_serviceResponse_common, MATLABROSMsgInterface<fishbot_ros::chess_serviceResponse>)
CLASS_LOADER_REGISTER_CLASS(fishbot_ros_chess_service_service, ROSMsgElementInterfaceFactory)
#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif //_MSC_VER
//gen-1
