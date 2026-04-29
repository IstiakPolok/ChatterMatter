part of 'explore_view.dart';

customTile({required Category category, required bool isSelected}) {
  final config = categoryTileConfigs[category.colorPalette]!;
  return Container(
    height: 185,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(defaultPadding),
      color: config.backgroundColor,
    ),
    child: Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: Image.asset(config.backgroundImage),
        ),

        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.title,
                        style: titleMedium(color: customWhite),
                      ),
                    ),
                    Checkbox(
                      value: isSelected,
                      onChanged: (e) {},
                      // fillColor: customWhite,
                      activeColor: customWhite,
                      checkColor: config.backgroundColor,
                    ),
                  ],
                ),
                // vPad10,
                Padding(
                  padding: EdgeInsets.only(right: 50),
                  child: Text(
                    category.subTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: bodyMedium(color: const Color(0xff7F4DA3)),
                  ),
                ),
                vPad20,
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: defaultPadding,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(defaultPadding),
                    color: customWhite,
                  ),
                  child: Text(
                    category.questionCount.toString(),
                    style: bodyMedium(color: customDarkPurple),
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: 20,
          right: 20,
          child: Image.asset(
            config.foregroundImage,
            height: 80,
            width: 80,
            fit: BoxFit.cover,
          ),
        ),
      ],
    ),
  );
}
