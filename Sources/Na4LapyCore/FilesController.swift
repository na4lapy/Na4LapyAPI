//
//  FilesController.swift
//  Na4lapyAPI
//
//  Created by scoot on 02.01.2017.
//
//

import Kitura
import LoggerAPI
import Foundation
import SwiftyJSON

public class FilesController {
    public let router = Router()
    let path: String
    let backend: Model
    
    public init(path: String, backend: Model) {
        self.path = path
        self.backend = backend
        setup()
    }

    //
    // MARK: konfiguracja routerów
    //
    
    private func setup() {
        router.get("/:id", handler: onGetbyId)
        router.post("/upload/:filename", handler: onUpload)
        router.delete("/:id", handler: onDelete)
        router.delete("/removeall/:animal", handler: onRemoveAll)
        router.patch("/:id", handler: onPatch)
    }

    //
    // MARK: obsługa requestów
    //
    private func onPatch(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let id = request.parameters["id"], let idint = Int(id)  else {
            Log.error("Brak parametru 'id' w zapytaniu.")
            try? response.status(.badRequest).end()
            return
        }
        
        let newProfilFlag: Bool = request.queryParameters["profil"] == "true" ? true : false
        
        do {
            _ = try checkSession(request: request, response: response)
            //
            // TODO: sprawdzić, czy shelter_id zwierzaka do którego nalezy zdjęcie pasuje do sesji
            //

            let id = try backend.edit(withDictionary: [PhotoJSON.id : idint, PhotoJSON.profil : newProfilFlag])
            try? response.status(.OK).send(json: JSON(["id" : id])).end()
        } catch (let error) {
            Log.error(error.localizedDescription)
            try? response.status(.notFound).end()
        }
    }

    private func onRemoveAll(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let animal = request.parameters["animal"], let animalid = Int(animal) else {
            Log.error("Brak parametru 'id' w zapytaniu.")
            try? response.status(.badRequest).end()
            return
        }
        
        do {
            _ = try checkSession(request: request, response: response)
            //
            // TODO: sprawdzić, czy shelter_id zwierzaka pasuje do sesji
            //

            let filename = try backend.deleteAll(byId: animalid)
            for item in filename {
                try FileManager().removeItem(atPath: path + item)
            }
            try? response.status(.OK).end()
        } catch (let error) {
            Log.error(error.localizedDescription)
            try? response.status(.notFound).end()
        }
    }

    private func onDelete(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let id = request.parameters["id"], let idint = Int(id) else {
            Log.error("Brak parametru 'id' w zapytaniu.")
            try? response.status(.badRequest).end()
            return
        }
        
        do {
            _ = try checkSession(request: request, response: response)
            //
            // TODO: sprawdzić, czy shelter_id zwierzaka pasuje do sesji
            //
            
            let filename = try backend.delete(byId: idint)
            try FileManager().removeItem(atPath: path + filename)
            try? response.status(.OK).end()
        } catch (let error) {
            Log.error(error.localizedDescription)
            try? response.status(.notFound).end()
        }
    }

    private func onUpload(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        var content = Data()

        guard
            let animalId = request.queryParameters["animalId"],
            let animalIntId = Int(animalId) else {
                Log.error("Błąd podczas uploadu pliku")
                response.status(.notFound)
                try? response.end()
                return
        }
        
        let profilFlag = request.queryParameters["profil"] ?? ""
        let filename = UUID().uuidString + ".jpg"
        
        do {
            _ = try checkSession(request: request, response: response)
            //
            // TODO: sprawdzić, czy shelter_id zwierzaka pasuje do sesji
            //
            
            _ = try request.read(into: &content)
            let url = URL(fileURLWithPath: path + filename)
            try content.write(to: url)
            let dictionary: JSONDictionary = [PhotoJSON.animalid : animalIntId, PhotoJSON.filename : filename, PhotoJSON.profil : profilFlag]
            let id = try backend.add(withDictionary: dictionary)
            try response.status(.OK).send(json: JSON(["id" : id])).end()
        } catch (let error) {
            Log.error(error.localizedDescription)
            try? response.status(.notFound).end()
        }
    }
    
    /**
     Pobranie obiektu na podstawie identyfikatora
     
     */
    private func onGetbyId(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let id = request.parameters["id"] else {
            Log.error("Brak parametru 'id' w zapytaniu.")
            try? response.status(.badRequest).end()
            return
        }

        // TODO: zadbać aby nazwa pliku nie zawierała ścieżki.
        
        do {
            // Brak sesji - włączenie cache.
            if request.session?[SecUserDBKey.shelterid].string == nil {
                response.headers.append(ResponseHeader.cacheControl, value: ResponseHeader.cacheControlValue)
            }
            try response.status(.OK).send(fileName: path + id).end()
        } catch {
            Log.error("Błąd podczas pobierania pliku: \(path + id)")
            try? response.status(.notFound).end()
        }
    }
    
    private func checkSession(request: RouterRequest, response: RouterResponse) throws -> Int {
        guard let sess = request.session, let shelterid = sess[SecUserDBKey.shelterid].string, let sessShelterid = Int(shelterid) else {
            Log.error("Wymagane uwierzytelnienie.")
            response.status(.forbidden)
            try? response.end()
            throw ResultCode.AuthorizationError
        }
        return sessShelterid
    }
}
