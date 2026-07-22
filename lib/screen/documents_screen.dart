import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DocumentsTabContent extends StatelessWidget {
  const DocumentsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search documents...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(Icons.filter_alt_outlined),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload),
              label: const Text("Upload"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0B3A75),
                foregroundColor: Colors.white,
                minimumSize: const Size(110, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              categoryChip("All", true),
              categoryChip("Brochures", false),
              categoryChip("Agreements", false),
              categoryChip("KYC", false),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              FileTile(
                fileType: "PDF",
                fileName: "Green_Valley_Brochure.pdf",
                uploader: "Amit Singh",
                size: "2.4 MB",
                date: "19 May 2025, 10:35 AM",
                tag: "Brochure",
                tagColor: const Color(0xFFD7F5E6),
                iconColor: Colors.red,
              ),
              const Divider(height: 1),
              FileTile(
                fileType: "JPG",
                fileName: "Site_Photo_1.jpg",
                uploader: "Amit Singh",
                size: "1.8 MB",
                date: "19 May 2025, 10:32 AM",
                tag: "Image",
                tagColor: const Color(0xFFE8F0FF),
                iconColor: Colors.blue,
              ),
              const Divider(height: 1),
              FileTile(
                fileType: "PDF",
                fileName: "Builder_Agreement.pdf",
                uploader: "Neha Verma",
                size: "3.1 MB",
                date: "18 May 2025, 04:15 PM",
                tag: "Agreement",
                tagColor: const Color(0xFFFFEFE0),
                iconColor: Colors.red,
              ),
              const Divider(height: 1),
              FileTile(
                fileType: "DOC",
                fileName: "KYC_Documents.docx",
                uploader: "Rahul Sharma",
                size: "4.5 MB",
                date: "18 May 2025, 11:20 AM",
                tag: "KYC",
                tagColor: const Color(0xFFF0E4FF),
                iconColor: Colors.indigo,
              ),
              const Divider(height: 1),
              FileTile(
                fileType: "PNG",
                fileName: "ID_Proof.png",
                uploader: "Rahul Sharma",
                size: "1.2 MB",
                date: "18 May 2025, 11:18 AM",
                tag: "KYC",
                tagColor: const Color(0xFFF0E4FF),
                iconColor: Colors.green,
              ),
            ],
          ),
        ),
        Container(
          width: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Showing 1 to 6 of 12 documents',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _pageButton(
                    icon: Icons.chevron_left,
                    isActive: false,
                  ),
                  _numberButton("1", active: true),
                  _numberButton("2"),
                  _numberButton("3"),
                  const Text(
                    "...",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Next"),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD9E4FF),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: Colors.blue,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Secure & Private",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F3B8F),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "All documents are securely stored and accessible only to authorized team members.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4A6FD3),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  static Widget _numberButton(
    String text, {
    bool active = false,
  }) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF0F2D6B) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active ? const Color(0xFF0F2D6B) : Colors.grey.shade300,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static Widget _pageButton({
    required IconData icon,
    bool isActive = false,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(
        icon,
        color: Colors.grey.shade600,
      ),
    );
  }
}

Widget categoryChip(String text, bool selected) {
  return Padding(
    padding: const EdgeInsets.only(right: 10),
    child: Chip(
      label: Text(text),
      backgroundColor: selected ? const Color(0xffE7F0FF) : Colors.white,
      side: BorderSide(
        color: selected ? Colors.blue.shade300 : Colors.grey.shade300,
      ),
    ),
  );
}

class FileTile extends StatelessWidget {
  final String fileType;
  final String fileName;
  final String uploader;
  final String size;
  final String date;
  final String tag;
  final Color tagColor;
  final Color iconColor;

  const FileTile({
    super.key,
    required this.fileType,
    required this.fileName,
    required this.uploader,
    required this.size,
    required this.date,
    required this.tag,
    required this.tagColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fileType,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 2),
                Icon(
                  Icons.insert_drive_file,
                  size: 16,
                  color: iconColor,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        fileName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tagColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Uploaded by $uploader",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$size • $date",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'view',
                child: Text('View'),
              ),
              PopupMenuItem(
                value: 'rename',
                child: Text('Rename'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
