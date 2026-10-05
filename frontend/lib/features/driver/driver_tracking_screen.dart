  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: DriverTheme.background,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 80),
                const Expanded(
                  child: Center(child: Text('Map')),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        );
      },
    );
  }