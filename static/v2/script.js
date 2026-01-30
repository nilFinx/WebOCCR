const results = document.getElementById("results");
const errors = document.getElementById("errors");

document.getElementById("submit").addEventListener("click", () => {
	const selectedFile = document.getElementById("plist").files[0];
	const checked = document.getElementById("expand").checked;
	if (selectedFile) {
		selectedFile.text()
		.then(plist => {
		results.innerHTML = "";
		errors.innerHTML = "	";
		fetch("/api/v2/check", {
			method: "POST",
			body: plist
		})
		.then(res => {
			if (!res.ok) {
				res.text()
				.then(res => {
					results.innerText = res;
					errors.innerText = res;
				});
			} else {
				res.json()
				.then (data => {
					errors.innerText = data.errors;
					if ("content" in document.createElement("template")) {
						const body = document.getElementById("results");
						const template = document.getElementById("row");
						const templateempty = document.getElementById("emptyrow");

						for (let i = 0; i < data.order.length; i++) {
							const k = data.order[i];
							const block = data.sections[k];
							if (block.text && block.text !== "") {
								console.log(block)
								const clone = template.content.cloneNode(true);
								if (checked) {
									clone.getElementById("dets").setAttribute("open", "");
								} else {
									clone.getElementById("dets").removeAttribute("open");
								}
								if (block.checked) {
									clone.getElementById("title").innerText = `${k} (${block.checked.toString()}/${block.total.toString()}):`;
								} else if (block.total) {
									clone.getElementById("title").innerText = `${k} (0/${block.total.toString()}):`;
								} else {
									clone.getElementById("title").innerText = k+":";
								}
								clone.getElementById("text").innerText = block.text;

								body.appendChild(clone);
							} else {
								const clone = templateempty.content.cloneNode(true);
								clone.getElementById("title").innerText = k;
								body.appendChild(clone);
							}
						}
					} else {
						let ht = "";
						for (let i = 0; i < data.order.length; i++) {
							const k = data.order[i];
							const block = data.sections[k];
							if (block.checked) {
								ht = ht + `${k} (${block.checked.toString()}/${block.total.toString()}):\n`;
							} else {
								ht = ht + `${k}:\n`;
							}
							ht = ht + block.text + "\n";
						}
						results.innerText = ht;
					}
				});
			}
		});
		});
	} else {
		alert("You need to select a plist");
	}
});