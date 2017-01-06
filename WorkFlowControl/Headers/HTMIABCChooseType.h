//
//  HTMIABCChooseType.h
//  MXClient
//
//  Created by wlq on 16/6/22.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#ifndef HTMIABCChooseType_h
#define HTMIABCChooseType_h
typedef NS_ENUM(NSInteger, ChooseType) {
    ChooseTypeDepartmentFromAll = 0,            //从所有部门中选择.
    ChooseTypeDepartmentFromSpecific,           //从指定的部门中选择
    ChooseTypeDepartmentFromSpecificOnly,       //只从指定的部门中选择，没有其他标签页
    ChooseTypeUserFromAll,                      //从所有人员中选择
    ChooseTypeUserFromSpecific,                 //从指定的人员中选择
    ChooseTypeUserFromSpecificOnly,             //只从指定的人员中选择,没有其他标签页
    ChooseTypeOrganization,                     //从组织机构选择，可能选人也可能是部门，只能单选
};

#endif /* HTMIABCChooseType_h */
