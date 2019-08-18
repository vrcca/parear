import Vue from 'vue'
import StairsServer from "./stairs_server"

let connectionView = function(server, translations) {
    let app = new Vue({
        el: "#connection-status",
        data: {
            connection: server.connection
        },
        computed: {
            status: function() {
                return {
                    connected: this.connection.status === "connected",
                    connecting: this.connection.status === "connecting",
                    disconnected: this.connection.status === "disconnected",
                    hidden: this.connection.status === "hidden"
                }
            },
            connection_status: function() {
                if (this.status.connected) {
                    let self = this;
                    setTimeout(() => {
                        self.connection.status = "hidden"
                    }, 1000);
                    return translations.connection_status.connected
                } else if (this.status.disconnected) {
                    return translations.connection_status.disconnected
                }
                return translations.connection_status.connecting
            }
        }
    })
}

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
                server.pair(participant, friend)
            },
            unpair: function(participant, friend) {
                server.unpair(participant, friend)
            }
        }
    })
}

window.onload = function() {
    let root = document.getElementById("pair-stairs")
    if (!root) {
        return;
    }
    // stairs defined in stairs/show.html.ex
    let server = new StairsServer(stairs)
    let app = view(server)
    let connectionStatus = connectionView(server, translations)
    server.connect()
}

let stairs_id_from = function(element) {
    return element.getAttribute('data-stairs-id');
}
