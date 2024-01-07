var SortUtils;

SortUtils = class SortUtils {
  static dynamicSort(property) {
    return function(a, b) {
      if (a[property] < b[property]) {
        return -1;
      } else if (a[property] > b[property]) {
        return 1;
      } else {
        return 0;
      }
    };
  }

  static dynamicMultiSort(props) {
    //save the arguments object as it will be overwritten
    //note that arguments object is an array-like object
    //consisting of the names of the properties to sort by
    return function(a, b) {
      var i, numberOfProps, result;
      i = 0;
      result = 0;
      numberOfProps = Array.isArray(props) ? props.length : props[0] = props;
      // try getting a different result from 0 (equal)
      // as long as we have extra properties to compare
      while (result === 0 && i < numberOfProps) {
        result = SortUtils.dynamicSort(props[i])(a, b);
        i++;
      }
      return result;
    };
  }

};
