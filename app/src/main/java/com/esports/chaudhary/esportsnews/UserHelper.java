package com.esports.chaudhary.esportsnews;


public class UserHelper {

    String name;
    String emailId;

    public UserHelper() {
    }

    public UserHelper(String name, String emailId){
        this.name = name;
        this.emailId= emailId;
    }
    public void setEmailId(String name, String emailId) {
        this.name = name;
        this.emailId = emailId;
    }

    public String getEmailId() {
        return emailId;
    }

    public String getName(){
        return name;
    }
}
