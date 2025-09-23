<template>
  <div class="mensajes-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Mensajes</li>
      </ol>
    </nav>
    <div class="card shadow-sm mx-auto" style="max-width: 600px;">
      <div class="card-header bg-primary text-white">
        <h5 class="mb-0">Mensaje</h5>
      </div>
      <div class="card-body d-flex align-items-center">
        <div class="me-3">
          <img v-if="imagenSrc" :src="imagenSrc" alt="Imagen" style="width: 48px; height: 48px; object-fit: contain;" />
          <div v-else style="width:48px;height:48px;background:#eee;border-radius:8px;display:flex;align-items:center;justify-content:center;">
            <i class="bi bi-info-circle" style="font-size:2rem;color:#aaa;"></i>
          </div>
        </div>
        <div class="flex-grow-1">
          <textarea v-model="mensaje" class="form-control fw-bold" rows="3" readonly></textarea>
        </div>
        <div class="ms-3">
          <button class="btn btn-success px-4" @click="onOk">OK</button>
        </div>
      </div>
      <div v-if="showSave" class="card-footer bg-light">
        <button class="btn btn-outline-primary" @click="saveMensaje">Guardar Mensaje</button>
      </div>
    </div>
    <div v-if="showList" class="mt-4">
      <h6>Historial de Mensajes</h6>
      <ul class="list-group">
        <li v-for="msg in mensajesList" :key="msg.id" class="list-group-item d-flex align-items-center">
          <span class="me-2">
            <img v-if="msg.imagen_url" :src="msg.imagen_url" alt="img" style="width:24px;height:24px;object-fit:contain;" />
            <i v-else class="bi bi-info-circle"></i>
          </span>
          <span>{{ msg.mensaje }}</span>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
export default {
  name: 'MensajesPage',
  data() {
    return {
      imagen: null, // integer or null
      mensaje: '',
      imagenSrc: null, // base64 or url
      showSave: true,
      showList: false,
      mensajesList: []
    };
  },
  created() {
    // Optionally, get params from route/query
    if (this.$route.query.mensaje) {
      this.mensaje = this.$route.query.mensaje;
    }
    if (this.$route.query.imagen) {
      this.imagen = parseInt(this.$route.query.imagen);
      this.loadImagen();
    }
    this.showList = !!this.$route.query.list;
    if (this.showList) {
      this.loadMensajes();
    }
  },
  methods: {
    onOk() {
      this.$router.push('/');
    },
    saveMensaje() {
      fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          eRequest: 'mensaje.save',
          params: {
            imagen: this.imagen,
            mensaje: this.mensaje
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse.success) {
            this.$bvToast && this.$bvToast.toast('Mensaje guardado', {variant:'success'});
            this.showSave = false;
            this.loadMensajes();
            this.showList = true;
          } else {
            alert(json.eResponse.message);
          }
        });
    },
    loadImagen() {
      // For demo, use a static image or map integer to image
      // In real app, fetch from API or assets
      if (this.imagen === 1) {
        this.imagenSrc = '/img/info.png';
      } else if (this.imagen === 2) {
        this.imagenSrc = '/img/warning.png';
      } else if (this.imagen === 3) {
        this.imagenSrc = '/img/error.png';
      } else {
        this.imagenSrc = null;
      }
    },
    loadMensajes() {
      fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          eRequest: 'mensaje.list',
          params: {}
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse.success) {
            this.mensajesList = (json.eResponse.data || []).map(msg => ({
              ...msg,
              imagen_url: msg.imagen === 1 ? '/img/info.png' : (msg.imagen === 2 ? '/img/warning.png' : (msg.imagen === 3 ? '/img/error.png' : null))
            }));
          }
        });
    }
  }
};
</script>

<style scoped>
.mensajes-page {
  padding: 2rem 0;
}
.card {
  border-radius: 12px;
}
textarea[readonly] {
  background: #f8f9fa;
  border: none;
  resize: none;
}
</style>
