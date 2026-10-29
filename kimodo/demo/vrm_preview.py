"""Embed the local VRoid renderer into Kimodo's existing Viser viewport."""
import json
import os
from pathlib import Path

from viser import _messages
from kimodo.exports.bvh import motion_to_bvh
from kimodo.skeleton import SOMASkeleton30, SOMASkeleton77


PREVIEW_URL = os.environ.get('KIMODO_VRM_PREVIEW_URL', 'http://127.0.0.1:8666/kimodo-preview.html')


def javascript(client, source):
    client._websock_connection.queue_message(_messages.RunJavascriptMessage(source=source))


def install(client):
    script = (Path(__file__).with_name('vrm_preview.js')).read_text()
    javascript(client, f'({script})({json.dumps(PREVIEW_URL)});')


def send(client, **payload):
    javascript(client, 'window.__kimodoVrm?.send(' + json.dumps({'channel': 'kimodo-vrm', **payload}) + ');')


def supported(session):
    return isinstance(session.skeleton, (SOMASkeleton30, SOMASkeleton77))


def publish(session, motion):
    if not supported(session):
        return
    bvh = motion_to_bvh(motion.joints_local_rot, motion.joints_pos[:, session.skeleton.root_idx],
                        skeleton=session.skeleton, fps=session.model_fps, standard_tpose=True)
    send(session.client, action='motion', id=motion.name, bvh=bvh)
    send(session.client, action='frame', frame=session.frame_idx)
