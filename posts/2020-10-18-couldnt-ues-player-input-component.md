Player Input����肭�g���Ȃ��Ǝv������P���ȃ~�X������

# tl;dr

UnityEvent���g�p����ꍇ�AEvent�ɓo�^����X�N���v�g�́A����Inspector�r���[����I�����A�X�N���v�g�t�@�C�����̂��̂����Ȃ��悤�ɂ���

---

Player Input�́AUnity��`2019.1`����ǉ����ꂽ�A`Input`�Ɏ���ĕς��V�������͊Ǘ��V�X�e���ł��B
�ڂ�����[�V���� Input System �̂��Љ� -- blogs.unity3d.com](https://blogs.unity3d.com/jp/2019/10/14/introducing-the-new-input-system/)���Q�Ƃ��Ă��������B


# ��

�\�t�g�E�F�A   �o�[�W����
-------------  --------------------- -
Unity          2019.4.11f1 Personal
InputSystem    1.0.0

# ����

��{�I�ɂ�[Quick Start Guide](https://docs.unity3d.com/Packages/com.unity.inputsystem@1.0/manual/QuickStartGuide.html)�ɉ����č�Ƃ����Ă��܂��B(`Input System`�͓����ςƂ��܂��B)

1. ���͂𔽉f��������`GameObject`��`PlayerInput`��attach���܂��B
2. "Create Actions"�������A�V����`Action Asset`���쐬���܂�
3. "Quick Start Guide"�ɏ]���āA���͂�`Unity Events`�Ŏ󂯂Ƃ�悤�ɂ��܂��B
4. ����͕K�v�Ȃ������̂ŁA�f�t�H���g�œ����Ă���Action�������Ŏg�����̂ɓ��ꂩ���܂���
5. `1.`��`GameObject`�ɖ߂�A`PlayerInput`��Events����Script file���w�肵�܂�
6. ����!?`No Function`�����o�Ă��Ȃ�!?

# ����

����̌����́A��L��`5.`�ɂ��� **Events���ɐݒ肵������** �ł����B
�����ŁA���́u�X�N���v�g�t�@�C�����́v��I�����Ă��܂������A�����ł͂Ȃ��A�u���ۂɎg�������I�u�W�F�N�g�ɕR�Â����Ă���Y���t�@�C���̃C���X�^���X��n���Ă�ƁA��肭�����܂��B

## ������l�����錴��

����͈Ⴂ�܂������A���ׂĂ���ԂɌ������̂�[����](https://forum.unity.com/threads/cant-assign-public-script-function-to-player-input-component-new-input-system.881032/)�ŁA�u�R�[���o�b�N�֐��̈�����`InputAction.CallbackContext callbackContext`�ɂ��Ȃ��Ƃ����Ȃ��A�Ƃ������́B
