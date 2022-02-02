@isTest
public with sharing class User_TestFactory {
    //Test Factory Controls
    public Boolean insertOnCreate = true;

    public User createSingleSandardUser() {
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User_TestFactory.Builder('TestUser1')
            .setProfileId(standardUserProfile.Id)
            .build();

        if(insertOnCreate) {
            insert u;
        }

        return u;
    }


    private static User buildUser(Builder builder) {
        User u = new User();

        u.lastName = builder.lastName;
        u.Alias = builder.alias;
        u.Email = builder.email;
        u.EmailEncodingKey = builder.emailEncodingKey;
        u.LanguageLocaleKey = builder.languageLocaleKey;
        u.LocaleSidKey = builder.localeSidKey;
        u.ProfileId = builder.profileId;
        u.TimeZoneSidKey = builder.timeZoneSidKey;
        u.Username = builder.username;
        
        return u;
    }

    public class Builder {
        //Mandatory
        private String lastName; 
        private String alias;
        private String email;
        private String emailEncodingKey;
        private String languageLocaleKey;
        private String localeSidKey;
        private Id profileId;
        private String timeZoneSidKey;
        private String username;

        //Optional
        private String productCode;

        //Constructor requires mandatory params
        public Builder(String lastName) {
            this.lastName = lastName;
            this.alias = lastName.substring(0, 5);
            this.email = lastname + 'bw@code.challenge';
            this.emailEncodingKey = 'UTF-8';
            this.LanguageLocaleKey = 'en_US';
            this.localeSidKey = 'en_US';
            this.timeZoneSidKey = 'Europe/London';

            Blob randomKey = Crypto.GenerateAESKey(128);
            String guidBase = EncodingUtil.convertToHex(randomKey);
            String guid = guidBase.substring(0, 8) + '-' + guidBase.substring(8, 12) + '-' + guidBase.substring(12, 16) + '-' + guidBase.substring(16, 20) + '-' + guidBase.substring(20);
            this.username = lastName + '.' + guid + '@code.challenge';

        }

        //Call at end to construct 
        public User build() {
            return User_TestFactory.buildUser(this);
        }

        public Builder setProfileId(Id profileId) {
            this.profileId = profileId;
            return this;
        }
    }
}
