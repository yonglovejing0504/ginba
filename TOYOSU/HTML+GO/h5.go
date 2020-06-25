package main

import (
    // "bytes"
    //"encoding/json"
    "fmt"
    //"io/ioutil"
    "log"
    "net/http"
   // "strings"
)

func main() {
    http.HandleFunc("/LoginCheck", sayHello)
    err := http.ListenAndServe(":9090", nil)

    if err != nil {
        log.Fatal("ListenAndServe: ", err)
    }
}

func sayHello(w http.ResponseWriter, r *http.Request) {
    r.ParseForm()

    if r.Method == "POST" {
        fmt.Println("recv form", r.Form)
		fmt.Println(r.Form["danjia"][0])
		fmt.Println(r.Form["shuliang"][0])
	}
}
