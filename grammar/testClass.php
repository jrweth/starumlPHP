<?php
namespace MyNamespace\MySubNameSpace\MySubNamespace2;

/* 
here is my test class
 * with some stuff
 * with some more stuff

*/
class myClass {
    /*
    */
    function myClassFunction() {
        //}}}somecrazy stuff in here;
        if ($something = $somethingelse) {
            if ('nestedBrackets') {
                $thisShould = 'still work'
            }    
        }
       
    }
    /**
    * here is some descriptive stuff
    */
    function myClassFunctionTwo(){

    }
    function _myClass4(){}


    /**
     * An internal function to check params for the construct method
     * @param array $data           The array of data to check
     * @param DataCheckErrorHolder  $errors  Error holder associated with the validation
     */
    protected static function _checkDataElements($data, ErrorHolder $errors)
    {
        foreach($data as $key => $value) {
            switch ($key) {
                case 'info':
                    if(($value  null is_scalar($value) is_callable([$value toString]))){
                        $errors->addError(new DataCheckError(
                            'info',
                            'The "'. $key .'" data element must be a string'
                        ));
                    } 
                    break;
            }
        }
        return !$errors->hasErrors();

    }   
}
