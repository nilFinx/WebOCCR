document.getElementById("submit").addEventListener("click", () => {
    const selectedFile = document.getElementById("plist").files[0];
    if (selectedFile) {
        selectedFile.text()
            .then(plist => {
                    fetch("/api/v1/check", {
                        method: "POST",
                        body: plist
                    })
                        .then(res => {
                            return res.text()
                        })
                        .then(res => {
                            document.getElementById("results").innerText = res;
                        })
            })
    } else {
        alert("You need to select a plist");
    }
});