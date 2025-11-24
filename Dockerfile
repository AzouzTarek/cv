# Étape 1 — Utiliser l'image officielle Nginx
FROM nginx:alpine

# Étape 2 — Supprimer la page par défaut de Nginx
RUN rm -rf /usr/share/nginx/html/*

# Étape 3 — Copier ton CV dans le répertoire web de Nginx
COPY index.html /usr/share/nginx/html/index.html

# Étape 4 — Exposer le port 80
EXPOSE 80

# Étape 5 — Démarrer Nginx (par défaut dans l'image)
CMD ["nginx", "-g", "daemon off;"]
