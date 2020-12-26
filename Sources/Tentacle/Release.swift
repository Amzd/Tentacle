//
//  Release.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/3/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation

extension Repository {
    /// A request to get the latest release for the repository.
    ///
    /// If the repository doesn't have any releases, this will result in a `.doesNotExist` error.
    ///
    /// https://developer.github.com/v3/repos/releases/#get-the-latest-release
    public var latestRelease: Request<Release> {
        return Request(method: .get, path: "/repos/\(owner)/\(name)/releases/latest")
    }

    /// A request for the release corresponding to the given tag.
    ///
    /// If the tag exists, but there's not a correspoding GitHub Release, this will result in a
    /// `.doesNotExist` error. This is indistinguishable from a nonexistent tag.
    ///
    /// https://developer.github.com/v3/repos/releases/#get-a-release-by-tag-name
    public func release(forTag tag: String) -> Request<Release> {
        return Request(method: .get, path: "/repos/\(owner)/\(name)/releases/tags/\(tag)")
    }
    
    /// A request for the releases in the repository.
    ///
    /// https://developer.github.com/v3/repos/releases/#list-releases-for-a-repository
    public var releases: Request<[Release]> {
        return Request(method: .get, path: "/repos/\(owner)/\(name)/releases")
    }
}

/// A Release of a Repository.
public struct Release: CustomStringConvertible, ResourceType, Identifiable {
    /// An Asset attached to a Release.
    public struct Asset: CustomStringConvertible, ResourceType, Identifiable {
        /// The unique ID for this release asset.
        public let id: ID<Asset>

        /// The filename of this asset.
        public let name: String

        /// The MIME type of this asset.
        public let contentType: String

        /// The URL at which the asset can be downloaded directly.
        public let url: URL
        
        /// The URL at which the asset can be downloaded via the API.
        public let apiURL: URL

        public var description: String {
            return "\(url)"
        }

        public init(id: ID<Asset>, name: String, contentType: String, url: URL, apiURL: URL) {
            self.id = id
            self.name = name
            self.contentType = contentType
            self.url = url
            self.apiURL = apiURL
        }

        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case contentType = "content_type"
            case url = "browser_download_url"
            case apiURL = "url"
        }
    }

    /// The unique ID of the release.
    public let id: ID<Release>

    /// Whether this release is a draft (only visible to the authenticted user).
    public let isDraft: Bool

    /// Whether this release represents a prerelease version.
    public let isPrerelease: Bool
    
    /// The name of the tag upon which this release is based.
    public let tag: String
    
    /// The name of the release.
    public let name: String?
    
    /// The web URL of the release.
    public let url: URL
    
    /// Any assets attached to the release.
    public let assets: [Asset]
    
    public var description: String {
        return "\(url)"
    }
    
    /// The date at which the release was published.
    public let publishedAt: Date
    
    public init(id: ID<Release>, tag: String, url: URL, name: String? = nil, isDraft: Bool = false, isPrerelease: Bool = false, assets: [Asset], publishedAt: Date) {
        self.id = id
        self.tag = tag
        self.url = url
        self.name = name
        self.isDraft = isDraft
        self.isPrerelease = isPrerelease
        self.assets = assets
        self.publishedAt = publishedAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case isDraft = "draft"
        case isPrerelease = "prerelease"
        case tag = "tag_name"
        case name
        case url = "html_url"
        case assets
        case publishedAt = "published_at"
    }
}

extension Release.Asset: Equatable {
    public static func ==(lhs: Release.Asset, rhs: Release.Asset) -> Bool {
        return lhs.id == rhs.id && lhs.url == rhs.url
    }
}

extension Release: Equatable {
    public static func ==(lhs: Release, rhs: Release) -> Bool {
        return lhs.id == rhs.id
            && lhs.tag == rhs.tag
            && lhs.url == rhs.url
            && lhs.name == rhs.name
            && lhs.isDraft == rhs.isDraft
            && lhs.isPrerelease == rhs.isPrerelease
            && lhs.assets == rhs.assets
    }
}
