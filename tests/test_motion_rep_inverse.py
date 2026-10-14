# SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

"""Round-trip checks of the motion-rep inverse paths (pelvis height regression)."""

import torch

from kimodo.motion_rep.reps import ArdyMotionRep, TMRMotionRep
from kimodo.skeleton import SOMASkeleton77


def _standing_motion(skeleton, T=4):
    """A rest-pose motion with the root at a realistic hip height."""
    local = torch.eye(3).repeat(1, T, skeleton.nbjoints, 1, 1)
    root = torch.zeros(1, T, 3)
    root[..., 1] = 0.95  # hips ~0.95 m above ground
    root[..., 0] = torch.linspace(0, 0.5, T)  # a bit of forward motion
    return local, root


def test_ardy_inverse_from_positions_keeps_pelvis_height():
    """`inverse(posed_joints_from="positions")` must restore the pelvis at the root height, not 0.

    The encoder drops the pelvis row from local_joints_positions; the inverse rebuilds it and
    previously left its y at 0 while every other joint carried the absolute height.
    """
    skeleton = SOMASkeleton77()
    rep = ArdyMotionRep(skeleton, fps=30)
    local, root = _standing_motion(skeleton)
    feats = rep(local, root, to_normalize=False)
    out = rep.inverse(feats, is_normalized=False, posed_joints_from="positions")
    pelvis = out["posed_joints"][..., skeleton.root_idx, :]
    assert torch.allclose(pelvis[..., 1], root[..., 1], atol=1e-5), pelvis[..., 1].flatten()[:3]
    # consistency with the rotations path
    out_rot = rep.inverse(feats, is_normalized=False, posed_joints_from="rotations")
    assert torch.allclose(out["posed_joints"], out_rot["posed_joints"], atol=1e-4)


def test_tmr_inverse_keeps_root_height():
    """TMRMotionRep.inverse must return root_positions with the true height, not y = 0."""
    skeleton = SOMASkeleton77()
    rep = TMRMotionRep(skeleton, fps=30)
    local, root = _standing_motion(skeleton)
    feats = rep(local, root, to_normalize=False)
    out = rep.inverse(feats, is_normalized=False)
    assert torch.allclose(out["root_positions"][..., 1], root[..., 1], atol=1e-5)
    pelvis = out["posed_joints"][..., skeleton.root_idx, :]
    assert torch.allclose(pelvis[..., 1], root[..., 1], atol=1e-5)
