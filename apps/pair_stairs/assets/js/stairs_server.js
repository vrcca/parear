import {Socket} from "phoenix"

export default class StairsServer {

    constructor(stairs) {
        this.stairs = stairs
        this.socket = new Socket("/socket", {})
        this.socket.connect()
    }

    connect() {
        this.setup_channel()
        this.channel
            .join()
            .receive("ok", resp => {
                console.log("Joined successfully", resp)
                this.fetch_stairs()
            })
            .receive("error", resp => {
                alert("Unable to join", resp)
                throw(resp)
            })        
    }

    setup_channel() {
        this.channel = this.socket.channel("stairs:" + this.stairs.id, {})
        this.channel.on("stairs", (stairs) => {
            this.copy_stairs(stairs)
        })
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
