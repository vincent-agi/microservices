#!/bin/bash

# Script de gestion des microservices
# Usage: ./microservices.sh [start|stop|restart|status|logs]

case "$1" in
    start)
        echo "Démarrage de tous les microservices..."
        docker-compose up -d --build
        echo "Tous les services sont démarrés!"
        echo ""
        echo "📍 URLs d'accès:"
        echo "  - UserService API:    http://localhost:3000"
        echo "  - CartService API:    http://localhost:5001"
        echo "  - OrderService API:   http://localhost:8080"
        echo ""
        echo "Administration des bases de données:"
        echo "  - User DB Admin:      http://localhost:8083"
        echo "  - Cart DB Admin:      http://localhost:8082"
        echo "  - Order DB Admin:     http://localhost:8084"
        ;;
    stop)
        echo "Arrêt de tous les microservices..."
        docker-compose down
        echo "Tous les services sont arrêtés!"
        ;;
    restart)
        echo "Redémarrage de tous les microservices..."
        docker-compose down
        docker-compose up -d
        echo "Tous les services ont été redémarrés!"
        ;;
    status)
        echo "État des microservices:"
        docker-compose ps
        ;;
    logs)
        if [ -n "$2" ]; then
            echo "Logs pour le service: $2"
            docker-compose logs -f "$2"
        else
            echo "Logs de tous les services:"
            docker-compose logs -f
        fi
        ;;
    build)
        echo "Reconstruction des images Docker..."
        docker-compose build --no-cache
        echo "Images reconstruites!"
        ;;
    clean)
        echo "Nettoyage complet (arrêt, suppression des conteneurs et volumes)..."
        docker-compose down -v --remove-orphans
        docker system prune -f
        echo "Nettoyage terminé!"
        ;;
    *)
        echo "Script de gestion des microservices"
        echo ""
        echo "Usage: $0 [COMMAND]"
        echo ""
        echo "Commands:"
        echo "  start     Démarre tous les microservices"
        echo "  stop      Arrête tous les microservices"
        echo "  restart   Redémarre tous les microservices"
        echo "  status    Affiche l'état de tous les services"
        echo "  logs      Affiche les logs (optionnel: nom du service)"
        echo "  build     Reconstruit toutes les images Docker"
        echo "  clean     Nettoyage complet (conteneurs + volumes)"
        echo ""
        echo "Exemples:"
        echo "  $0 start"
        echo "  $0 logs user-api"
        echo "  $0 status"
        exit 1
        ;;
esac