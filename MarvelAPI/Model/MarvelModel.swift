//
//  MarvelModel.swift
//  MarvelAPI
//
//  Created by adrian.a.fernandez on 12/10/2018.
//  Copyright © 2018 adrian.a.fernandez. All rights reserved.
//

struct MarvelModel: Codable {
    var code: Int
    var status: String
    var etag: String
    var copyright: String
    var attributionText: String
    var attributionHTML: String
    var data: Container
}

struct Container: Codable {
    var offset: Int
    var limit: Int
    var total: Int
    var count: Int
    var results: [MarvelCharacter]
}

struct MarvelCharacter: Codable {
    var id: Int
    var name: String
    var description: String
    var modified: String
    var resourceURI: String
    var urls: [MarvelURL]
    var thumbnail: MarvelImage
//    var comics    ResourceList    A resource list containing comics which feature this character.
//    var stories    ResourceList    A resource list of stories in which this character appears.
//    var events    ResourceList    A resource list of events in which this character appears.
//    var series    ResourceList
}

struct MarvelImage: Codable {
    var path: String
    var `extension`: String
}

struct MarvelURL: Codable {
    var type: String
    var url: String
}
