package main

import (
    "net/http"
  //  "fmt"
    "log"

  //  "bytes"
  //  "encoding/json"
    "io"
  //  "strings"
)

func main() {
    http.HandleFunc("/Login?name1=zhang&name2=yong", FormServer)

    err := http.ListenAndServe(":9090", nil)

    if err != nil {
        log.Fatal("ListenAndServe: ", err)
    }

}


func FormServer(w http.ResponseWriter, request *http.Request) {

    w.Header().Set("Content-Type", "text/html")
    log.Printf(request.FormValue("name1"))

    switch request.Method {
    case "GET":
        /* display the form to the user */
        //io.WriteString(w, form)
        
    case "POST":
        io.WriteString(w, request.FormValue("userid"))
        io.WriteString(w, request.FormValue("password"))
    }
}
