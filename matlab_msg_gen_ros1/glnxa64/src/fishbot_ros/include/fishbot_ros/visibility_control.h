#ifndef FISHBOT_ROS__VISIBILITY_CONTROL_H_
#define FISHBOT_ROS__VISIBILITY_CONTROL_H_
#if defined _WIN32 || defined __CYGWIN__
  #ifdef __GNUC__
    #define FISHBOT_ROS_EXPORT __attribute__ ((dllexport))
    #define FISHBOT_ROS_IMPORT __attribute__ ((dllimport))
  #else
    #define FISHBOT_ROS_EXPORT __declspec(dllexport)
    #define FISHBOT_ROS_IMPORT __declspec(dllimport)
  #endif
  #ifdef FISHBOT_ROS_BUILDING_LIBRARY
    #define FISHBOT_ROS_PUBLIC FISHBOT_ROS_EXPORT
  #else
    #define FISHBOT_ROS_PUBLIC FISHBOT_ROS_IMPORT
  #endif
  #define FISHBOT_ROS_PUBLIC_TYPE FISHBOT_ROS_PUBLIC
  #define FISHBOT_ROS_LOCAL
#else
  #define FISHBOT_ROS_EXPORT __attribute__ ((visibility("default")))
  #define FISHBOT_ROS_IMPORT
  #if __GNUC__ >= 4
    #define FISHBOT_ROS_PUBLIC __attribute__ ((visibility("default")))
    #define FISHBOT_ROS_LOCAL  __attribute__ ((visibility("hidden")))
  #else
    #define FISHBOT_ROS_PUBLIC
    #define FISHBOT_ROS_LOCAL
  #endif
  #define FISHBOT_ROS_PUBLIC_TYPE
#endif
#endif  // FISHBOT_ROS__VISIBILITY_CONTROL_H_
// Generated 12-Oct-2023 14:32:58
// Copyright 2019-2020 The MathWorks, Inc.
