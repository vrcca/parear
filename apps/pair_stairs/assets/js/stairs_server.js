import {Socket} from "phoenix"

export default class StairsServer {

    constructor(stairs) {
        this.stairs = stairs
        this.connection = {
            status: "connecting"
        }
        this.socket = new Socket("/socket", {})
        this.socket.connect()
    }

    connect() {
        this.setup_channel()
        this.channel
            .join()
            .receive("ok", resp => {
                console.log("Joined successfully", resp)
                this.connection.status = "connected"
            })
            .receive("error", resp => {
                console.log("Unable to join", resp)
                this.connection.status = "disconnected"
                throw(resp)
            })

        this.socket
            .onClose(() => {
                console.log("Disconnected. Trying to reconnect...")
                this.connection.status = "connecting"
            })
        this.socket
            .onError(() => {
                console.log("there was an error with the connection!")
                this.connection.status = "disconnected"
            })
    }

    setup_channel() {
        this.channel = this.socket.channel("stairs:" + this.stairs.id, {})
        this.channel.on("stairs", (stairs) => {
            this.copy_stairs(stairs)
        })
        this.channel.onError(() => console.log("there was an error!") )
        this.channel.onClose(() => console.log("the channel has gone away gracefully") )
    }

    fetch_stairs() {
        this.channel.push("stairs", {})
    }

    copy_stairs(from) {
        for (let k in from) {
            this.stairs[k] = from[k]
        }
    }

    pair(participant, friend) {
        this.channel.push("pair", {
            participant: participant,
            friend: friend
        })
    }

    unpair(participant, friend) {
        this.channel.push("unpair", {
            participant: participant,
            friend: friend
        })
    }
}
