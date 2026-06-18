use college_nosql
db.createCollection("feedback")

db.feedback.insertMany([
  {
    student_id: 1,
    course_code: "CS101",
    semester: "2022-ODD",
    rating: 5,
    comments: "Excellent teaching. Best course so far.",
    tags: ["challenging", "well-structured", "good-examples"],
    submitted_at: ISODate("2022-11-30T10:15:00Z"),
    attachments: [{ filename: "notes.pdf", size_kb: 240 }]
  },
  {
    student_id: 2,
    course_code: "CS101",
    semester: "2022-ODD",
    rating: 4,
    comments: "Good content, well paced.",
    tags: ["challenging", "good-examples"],
    submitted_at: ISODate("2022-11-29T09:00:00Z"),
    attachments: [{ filename: "summary.pdf", size_kb: 120 }]
  },
  {
    student_id: 5,
    course_code: "CS101",
    semester: "2022-ODD",
    rating: 2,
    comments: "Too fast, hard to follow.",
    tags: ["challenging", "difficult"],
    submitted_at: ISODate("2022-11-28T14:00:00Z"),
    attachments: [{ filename: "doubts.txt", size_kb: 10 }]
  },
  {
    student_id: 1,
    course_code: "CS102",
    semester: "2022-ODD",
    rating: 4,
    comments: "Very practical and interesting.",
    tags: ["well-structured", "interesting"],
    submitted_at: ISODate("2022-11-30T11:00:00Z"),
    attachments: [{ filename: "lab_notes.pdf", size_kb: 310 }]
  },
  {
    student_id: 5,
    course_code: "CS102",
    semester: "2022-ODD",
    rating: 5,
    comments: "Loved every session.",
    tags: ["excellent", "well-structured"],
    submitted_at: ISODate("2022-11-27T08:30:00Z"),
    attachments: [{ filename: "project.pdf", size_kb: 450 }]
  },
  {
    student_id: 2,
    course_code: "CS103",
    semester: "2022-ODD",
    rating: 5,
    comments: "OOP concepts were crystal clear.",
    tags: ["excellent", "good-examples"],
    submitted_at: ISODate("2022-11-26T16:00:00Z"),
    attachments: [{ filename: "oop_notes.pdf", size_kb: 200 }]
  },
  {
    student_id: 8,
    course_code: "CS103",
    semester: "2022-ODD",
    rating: 3,
    comments: "Average. Could be better.",
    tags: ["well-structured", "average"],
    submitted_at: ISODate("2022-11-25T13:00:00Z")
  },
  {
    student_id: 3,
    course_code: "EC101",
    semester: "2021-EVEN",
    rating: 1,
    comments: "Very difficult to understand.",
    tags: ["difficult", "needs-improvement"],
    submitted_at: ISODate("2021-12-01T10:00:00Z"),
    attachments: [{ filename: "circuit_notes.pdf", size_kb: 180 }]
  },
  {
    student_id: 6,
    course_code: "EC101",
    semester: "2021-EVEN",
    rating: 2,
    comments: "Needed more practical examples.",
    tags: ["challenging", "difficult"],
    submitted_at: ISODate("2021-12-02T09:00:00Z"),
    attachments: [{ filename: "ec_summary.pdf", size_kb: 95 }]
  },
  {
    student_id: 4,
    course_code: "ME101",
    semester: "2023-ODD",
    rating: 4,
    comments: "Well taught with real-world examples.",
    tags: ["well-structured", "good-examples"],
    submitted_at: ISODate("2023-11-20T11:00:00Z"),
    attachments: [{ filename: "thermo_notes.pdf", size_kb: 300 }]
  },
  {
    student_id: 7,
    course_code: "ME101",
    semester: "2023-ODD",
    rating: 3,
    comments: "Decent course overall.",
    tags: ["average", "easy"],
    submitted_at: ISODate("2023-11-21T14:00:00Z"),
    attachments: [{ filename: "me_notes.pdf", size_kb: 150 }]
  },
  {
    student_id: 8,
    course_code: "CS101",
    semester: "2022-ODD",
    rating: 5,
    comments: "Fantastic! Would take again.",
    tags: ["excellent", "challenging", "well-structured"],
    submitted_at: ISODate("2022-11-30T15:00:00Z"),
    attachments: [{ filename: "full_notes.pdf", size_kb: 500 }]
  }
])

db.feedback.countDocuments()

db.feedback.find({ rating: 5 }).pretty()

db.feedback.find({ course_code: "CS101", tags: "challenging" }).pretty()

db.feedback.find({}, { student_id: 1, course_code: 1, rating: 1, _id: 0 })

db.feedback.updateMany(
  { rating: { $lt: 3 } },
  { $set: { needs_review: true } }
)

db.feedback.updateMany(
  { needs_review: true },
  { $push: { tags: "reviewed" } }
)

db.feedback.deleteMany({ semester: "2021-EVEN" })

db.feedback.aggregate([
  { $match: { semester: "2022-ODD" } },
  {
    $group: {
      _id: "$course_code",
      average_rating: { $avg: "$rating" },
      feedback_count: { $sum: 1 }
    }
  },
  {
    $project: {
      _id: 0,
      course_code: "$_id",
      average_rating: { $round: ["$average_rating", 1] },
      feedback_count: 1
    }
  },
  { $sort: { average_rating: -1 } }
])

db.feedback.aggregate([
  { $unwind: "$tags" },
  { $group: { _id: "$tags", count: { $sum: 1 } } },
  { $sort: { count: -1 } }
])

db.feedback.createIndex({ course_code: 1 })

db.feedback.find({ course_code: "CS101" }).explain("executionStats")
