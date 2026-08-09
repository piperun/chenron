import "dart:io";

import "package:cache_manager/cache_manager.dart";
import "package:chenron/services/metadata/metadata_parser.dart";
import "package:chenron/services/metadata/metadata_quality.dart";
import "package:flutter_test/flutter_test.dart";

String fixture(String name) => File(
      "apps/chenron/test/services/metadata/fixtures/$name",
    ).readAsStringSync();

void main() {
  group("evaluateMetadataQuality", () {
    // Catches acceptance of a bot-protection page as usable page metadata.
    test("rejects a Cloudflare-style challenge document", () {
      final decision = evaluateMetadataQuality(
        requestedUrl: "https://example.com/post/1",
        resolvedUrl: "https://example.com/post/1",
        statusCode: 200,
        contentType: "text/html; charset=utf-8",
        body: fixture("challenge.html"),
        parsed: const ParsedMetadata(title: "Just a moment..."),
      );

      expect(decision, isA<RejectedMetadataQuality>());
      expect(
        (decision as RejectedMetadataQuality).kind,
        MetadataFailureKind.challenge,
      );
    });

    // Catches persisting a spacing-equivalent site name as a page title.
    test("drops domain title but accepts a meaningful image", () {
      final decision = evaluateMetadataQuality(
        requestedUrl: "https://media.example/index.php?page=post&s=list&tags=x",
        resolvedUrl: "https://media.example/index.php?page=post&s=list&tags=x",
        statusCode: 200,
        contentType: "text/html",
        body: "<html></html>",
        parsed: const ParsedMetadata(
          title: "Media",
          imageUrl: "https://cdn.example/x.jpg",
        ),
      ) as AcceptedMetadataQuality;

      expect(decision.candidate.title, isNull);
      expect(decision.candidate.imageUrl, "https://cdn.example/x.jpg");
    });

    // Catches accepting a document after every field has normalized away.
    test("rejects a response with no meaningful fields", () {
      final decision = evaluateMetadataQuality(
        requestedUrl: "https://example.com/post/1",
        resolvedUrl: "https://example.com/post/1",
        statusCode: 200,
        contentType: "text/html",
        body: "<title>Example</title>",
        parsed: const ParsedMetadata(
          title: "Example",
          description: "https://example.com/post/1",
        ),
      );

      expect(decision, isA<RejectedMetadataQuality>());
      expect(
        (decision as RejectedMetadataQuality).kind,
        MetadataFailureKind.noUsableMetadata,
      );
    });

    // Catches non-success HTTP responses being treated as valid metadata.
    test("classifies blocked, rate-limited, and other HTTP responses", () {
      final blocked = evaluateMetadataQuality(
        requestedUrl: "https://example.com/post/1",
        resolvedUrl: "https://example.com/post/1",
        statusCode: 403,
        contentType: "text/html",
        body: "",
        parsed: const ParsedMetadata(title: "Meaningful title"),
      ) as RejectedMetadataQuality;
      final rateLimited = evaluateMetadataQuality(
        requestedUrl: "https://example.com/post/1",
        resolvedUrl: "https://example.com/post/1",
        statusCode: 429,
        contentType: "text/html",
        body: "",
        parsed: const ParsedMetadata(title: "Meaningful title"),
      ) as RejectedMetadataQuality;
      final serverError = evaluateMetadataQuality(
        requestedUrl: "https://example.com/post/1",
        resolvedUrl: "https://example.com/post/1",
        statusCode: 500,
        contentType: "text/html",
        body: "",
        parsed: const ParsedMetadata(title: "Meaningful title"),
      ) as RejectedMetadataQuality;

      expect(blocked.kind, MetadataFailureKind.blocked);
      expect(rateLimited.kind, MetadataFailureKind.rateLimited);
      expect(serverError.kind, MetadataFailureKind.httpStatus);
    });

    // Catches storing media or non-web image URLs as preview images.
    test("drops unsupported image URLs when another field is meaningful", () {
      final decision = evaluateMetadataQuality(
        requestedUrl: "https://example.com/post/1",
        resolvedUrl: "https://example.com/post/1",
        statusCode: 200,
        contentType: "text/html",
        body: "",
        parsed: const ParsedMetadata(
          title: "Meaningful title",
          imageUrl: "ftp://example.com/preview.mp4",
        ),
      ) as AcceptedMetadataQuality;

      expect(decision.candidate.imageUrl, isNull);
    });

    // Catches malformed HTTP-looking URLs being stored as preview images.
    test("drops an HTTP image URL without an authority", () {
      final decision = evaluateMetadataQuality(
        requestedUrl: "https://example.com/post/1",
        resolvedUrl: "https://example.com/post/1",
        statusCode: 200,
        contentType: "text/html",
        body: "",
        parsed: const ParsedMetadata(
          title: "Meaningful title",
          imageUrl: "https:/image.jpg",
        ),
      ) as AcceptedMetadataQuality;

      expect(decision.candidate.imageUrl, isNull);
    });

    // Coverage: protects the requirement that one challenge signal is not enough.
    test("accepts an ordinary page with only a challenge title", () {
      final decision = evaluateMetadataQuality(
        requestedUrl: "https://example.com/post/1",
        resolvedUrl: "https://example.com/post/1",
        statusCode: 200,
        contentType: "text/html",
        body: "<html></html>",
        parsed: const ParsedMetadata(title: "Just a moment..."),
      );

      expect(decision, isA<AcceptedMetadataQuality>());
    });

    // Catches CAPTCHA forms being missed as the second challenge signal.
    test("rejects a challenge title paired with an interstitial form", () {
      final decision = evaluateMetadataQuality(
        requestedUrl: "https://example.com/post/1",
        resolvedUrl: "https://example.com/post/1",
        statusCode: 200,
        contentType: "text/html",
        body: fixture("challenge_form.html"),
        parsed: const ParsedMetadata(title: "Just a moment..."),
      );

      expect(decision, isA<RejectedMetadataQuality>());
      expect(
        (decision as RejectedMetadataQuality).kind,
        MetadataFailureKind.challenge,
      );
    });
  });
}
