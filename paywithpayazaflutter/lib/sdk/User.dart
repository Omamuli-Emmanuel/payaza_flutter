class UserData {
  late String lastName;
  late String firstName;
  late String email;
  late String transactionRefff;

  //set lastname
  set setLastName(String lname){
    this.lastName = lname;
  }
  //get last name
  String get getLastName{
    return lastName;
  }

  //set first name
  set setFirstName(String fname){
    this.firstName = fname;
  }

  //get first name
  String get getFirstName{
    return firstName;
  }

  //set email
  set setEmail(String email){
    this.email = email;
  }
  //get email
  String get getEmail{
    return email;
  }

  //set transactionRef
  set transactionReff(String transaction){
    this.transactionRefff = transaction;
  }

  //get transactionref
  String get transaction{
    return transactionRefff;
  }


}