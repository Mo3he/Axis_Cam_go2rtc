// Fictional sample rows for the offline UI; refresh them by copying the current app UI and adapting its visible sample state.
"use strict";

const sampleStreams = [
  { name: "sample-entry", status: "Sample ready", consumers: "0" },
  { name: "sample-overview", status: "Sample idle", consumers: "0" },
];

const rows = document.getElementById("streams");
for (const stream of sampleStreams) {
  const row = document.createElement("tr");
  for (const [value, className] of [
    [stream.name, ""],
    [stream.status, "state"],
    [stream.consumers, "hide-small"],
  ]) {
    const cell = document.createElement("td");
    cell.textContent = value;
    if (className) cell.className = className;
    row.append(cell);
  }
  rows.append(row);
}
