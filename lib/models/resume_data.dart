class ResumeData {
  final String fe;
  final String fd;
  final String nv;

  const ResumeData({this.fe = '0', this.fd = '0', this.nv = '0'});

  @override
  String toString() {
    return 'ResumeData(fe: $fe, fd: $fd, nv: $nv)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ResumeData &&
        other.fe == fe &&
        other.fd == fd &&
        other.nv == nv;
  }

  @override
  int get hashCode => fe.hashCode ^ fd.hashCode ^ nv.hashCode;

  String getCopyText() {
    return '➡ Total FE: $fe\n'
        '➡ Total FD: $fd\n'
        '➡ Total NV: $nv';
  }
}
