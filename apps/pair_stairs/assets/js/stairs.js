import StairsServer from "./stairs_server"
import Vue from 'vue'

let view = function(server) {
    let app = new Vue({
        el: "#pair-stairs",
        data: {
            stairs: server.stairs
        },
        methods: {
            statuses_for: function(id, friend_id) {
                let statuses = this.stairs.statuses
                let friends = statuses[id]
                if (!friends) {
                    return 0;
                }
                let total = friends[friend_id]
                if (total) {
                    return total;
                }
                return 0;
            },
            pair: function(participant, friend) {
                server.pair(participant.name, friend.name)
            },
            unpair: function(participant, friend) {
                server.unpair(participant.name, friend.name)
            }
        }
    })
}

window.onload = function() {
    let root = document.getElementById("pair-stairs")
    if (!root) {
        return;
    }
    let stairs = {
        id: stairs_id_from(root),
        participants: {
            "a": {"id": "a", "name": "Loading..."},
            "b": {"id": "b", "name": "Loading..."},
            "c": {"id": "c", "name": "Loading..."},
            "d": {"id": "d", "name": "Loading..."},
            "e": {"id": "e", "name": "Loading..."}
        },
        statuses: {
        }
    }
    let server = new StairsServer(stairs)
    let app = view(server)
    server.connect()
}

let stairs_id_from = function(element) {
    return element.getAttribute('data-stairs-id');
}
