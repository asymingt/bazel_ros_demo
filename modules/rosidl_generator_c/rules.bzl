# Copyright 2025 Open Source Robotics Foundation, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("@rules_cc//cc:defs.bzl", "CcInfo", "cc_common")
load("@ros//:defs.bzl", "RosInterfaceInfo")
load("@rosidl_adapter//:aspects.bzl", "idl_aspect")
load("@rosidl_adapter_proto//:aspects.bzl", "proto_aspect")
load("@rosidl_generator_type_description//:aspects.bzl", "type_description_aspect")
load("@rosidl_generator_cpp//:aspects.bzl", "cc_aspect")
load("@rosidl_typesupport_c//:aspects.bzl", "c_typesupport_aspect")
load(":aspects.bzl", "c_aspect")
load(":types.bzl", "RosCBindingsInfo")

def _c_ros_library_impl(ctx):
    cc_infos = []
    for dep in ctx.attr.deps:
        cc_infos.extend(dep[RosCBindingsInfo].cc_infos.to_list())
    return [
        cc_common.merge_cc_infos(direct_cc_infos = cc_infos),
        DefaultInfo(
            files = depset(
                transitive = [
                    dep[RosCBindingsInfo].cc_files
                        for dep in ctx.attr.deps if RosCBindingsInfo in dep
                ]
            )
        ),
    ]

c_ros_library = rule(
    implementation = _c_ros_library_impl,
    attrs = {
        "deps": attr.label_list(
            aspects = [
                idl_aspect,               # RosIdlInfo
                proto_aspect,             # ProtoInfo, CcInfo
                type_description_aspect,  # RosTypeDescriptionInfo
                c_aspect,                 # RosCBindingsInfo
                cc_aspect,                # RosCcBindingsInfo
                c_typesupport_aspect,     # RosCcTypesupportInfo
            ],
            providers = [RosInterfaceInfo],
            allow_files = False,
        ),
    },
    provides = [CcInfo, DefaultInfo],
)

