class ProjectModel {
  String? projectName;
  String? description;
  String? createdAt;
  String? lastUpdated;
  String? coverImage;
  List<Platforms>? platforms;
  Links? links;
  Meta? meta;

  ProjectModel(
      {this.projectName,
      this.description,
      this.createdAt,
      this.lastUpdated,
      this.coverImage,
      this.platforms,
      this.links,
      this.meta});

  ProjectModel.fromJson(Map<String, dynamic> json) {
    projectName = json['projectName'];
    description = json['description'];
    createdAt = json['createdAt'];
    lastUpdated = json['lastUpdated'];
    coverImage = json['coverImage'];
    if (json['platforms'] != null) {
      platforms = <Platforms>[];
      json['platforms'].forEach((v) {
        platforms!.add(new Platforms.fromJson(v));
      });
    }
    links = json['links'] != null ? new Links.fromJson(json['links']) : null;
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['projectName'] = this.projectName;
    data['description'] = this.description;
    data['createdAt'] = this.createdAt;
    data['lastUpdated'] = this.lastUpdated;
    data['coverImage'] = this.coverImage;
    if (this.platforms != null) {
      data['platforms'] = this.platforms!.map((v) => v.toJson()).toList();
    }
    if (this.links != null) {
      data['links'] = this.links!.toJson();
    }
    if (this.meta != null) {
      data['meta'] = this.meta!.toJson();
    }
    return data;
  }
}

class Platforms {
  String? name;
  List<Groups>? groups;
  Content? content;
  bool? isShared;
  String? shareURL;
  String? repoURL;

  Platforms(
      {this.name,
      this.groups,
      this.content,
      this.isShared,
      this.shareURL,
      this.repoURL});

  Platforms.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['groups'] != null) {
      groups = <Groups>[];
      json['groups'].forEach((v) {
        groups!.add(new Groups.fromJson(v));
      });
    }
    content =
        json['content'] != null ? new Content.fromJson(json['content']) : null;
    isShared = json['isShared'];
    shareURL = json['shareURL'];
    repoURL = json['repoURL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    if (this.groups != null) {
      data['groups'] = this.groups!.map((v) => v.toJson()).toList();
    }
    if (this.content != null) {
      data['content'] = this.content!.toJson();
    }
    data['isShared'] = this.isShared;
    data['shareURL'] = this.shareURL;
    data['repoURL'] = this.repoURL;
    return data;
  }
}

class Groups {
  String? name;
  bool? selected;

  Groups({this.name, this.selected});

  Groups.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    selected = json['selected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['selected'] = this.selected;
    return data;
  }
}

class Content {
  String? post;
  String? lastEdited;
  String? title;
  String? readme;

  Content({this.post, this.lastEdited, this.title, this.readme});

  Content.fromJson(Map<String, dynamic> json) {
    post = json['post'];
    lastEdited = json['lastEdited'];
    title = json['title'];
    readme = json['readme'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['post'] = this.post;
    data['lastEdited'] = this.lastEdited;
    data['title'] = this.title;
    data['readme'] = this.readme;
    return data;
  }
}

class Links {
  String? liveDemo;
  String? portfolio;
  String? github;
  String? linkedin;
  String? email;

  Links(
      {this.liveDemo, this.portfolio, this.github, this.linkedin, this.email});

  Links.fromJson(Map<String, dynamic> json) {
    liveDemo = json['liveDemo'];
    portfolio = json['portfolio'];
    github = json['github'];
    linkedin = json['linkedin'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['liveDemo'] = this.liveDemo;
    data['portfolio'] = this.portfolio;
    data['github'] = this.github;
    data['linkedin'] = this.linkedin;
    data['email'] = this.email;
    return data;
  }
}

class Meta {
  int? tokenUsage;
  int? generationSteps;
  List<String>? sharedToPlatforms;
  String? saveSlot;

  Meta(
      {this.tokenUsage,
      this.generationSteps,
      this.sharedToPlatforms,
      this.saveSlot});

  Meta.fromJson(Map<String, dynamic> json) {
    tokenUsage = json['tokenUsage'];
    generationSteps = json['generationSteps'];
    sharedToPlatforms = json['sharedToPlatforms'].cast<String>();
    saveSlot = json['saveSlot'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tokenUsage'] = this.tokenUsage;
    data['generationSteps'] = this.generationSteps;
    data['sharedToPlatforms'] = this.sharedToPlatforms;
    data['saveSlot'] = this.saveSlot;
    return data;
  }
}
