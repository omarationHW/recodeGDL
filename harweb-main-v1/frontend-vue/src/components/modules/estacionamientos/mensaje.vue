<template>
  <div class="mensaje-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Mensaje del Sistema</li>
      </ol>
    </nav>
    <div class="card mx-auto" style="max-width: 500px;">
      <div class="card-header text-center">
        <h5>{{ tipo }}</h5>
      </div>
      <div class="card-body d-flex align-items-center">
        <div class="me-3">
          <div v-if="icono === 'pregunta'" class="icon-container text-primary">
            <svg width="48" height="48" fill="currentColor" class="bi bi-question-circle-fill" viewBox="0 0 16 16">
              <path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM5.496 6.033h.825c.138 0 .248-.113.266-.25.09-.656.54-1.134 1.342-1.134.686 0 1.314.343 1.314 1.168 0 .635-.374.927-.965 1.371-.673.489-1.206 1.06-1.168 1.987l.003.217a.25.25 0 0 0 .25.246h.811a.25.25 0 0 0 .25-.25v-.105c0-.718.273-.927 1.01-1.486.609-.463 1.244-.977 1.244-2.056 0-1.511-1.276-2.241-2.673-2.241-1.267 0-2.655.59-2.75 2.286a.237.237 0 0 0 .241.247zm2.325 6.443c.61 0 1.029-.394 1.029-.927 0-.552-.42-.94-1.029-.94-.584 0-1.009.388-1.009.94 0 .533.425.927 1.01.927z"/>
            </svg>
          </div>
          <div v-else-if="icono === 'admiracion'" class="icon-container text-warning">
            <svg width="48" height="48" fill="currentColor" class="bi bi-exclamation-triangle-fill" viewBox="0 0 16 16">
              <path d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5c.535 0 .954.462.9.995l-.35 3.507a.552.552 0 0 1-1.1 0L7.1 5.995A.905.905 0 0 1 8 5zm.002 6a1 1 0 1 1 0 2 1 1 0 0 1 0-2z"/>
            </svg>
          </div>
          <div v-else-if="icono === 'alto'" class="icon-container text-danger">
            <svg width="48" height="48" fill="currentColor" class="bi bi-stop-circle-fill" viewBox="0 0 16 16">
              <path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM6.5 5A1.5 1.5 0 0 0 5 6.5v3A1.5 1.5 0 0 0 6.5 11h3A1.5 1.5 0 0 0 11 9.5v-3A1.5 1.5 0 0 0 9.5 5h-3z"/>
            </svg>
          </div>
          <div v-else-if="icono === 'informacion'" class="icon-container text-info">
            <svg width="48" height="48" fill="currentColor" class="bi bi-info-circle-fill" viewBox="0 0 16 16">
              <path d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zm.93-9.412-1 4.705c-.07.34.029.533.304.533.194 0 .487-.07.686-.246l-.088.416c-.287.346-.92.598-1.465.598-.703 0-1.002-.422-.808-1.319l.738-3.468c.064-.293.006-.399-.287-.47l-.451-.081.082-.381 2.29-.287zM8 5.5a1 1 0 1 1 0-2 1 1 0 0 1 0 2z"/>
            </svg>
          </div>
          <div v-else class="icon-container text-secondary">
            <svg width="48" height="48" fill="currentColor" class="bi bi-chat-square-text-fill" viewBox="0 0 16 16">
              <path d="M0 2a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2h-2.5a1 1 0 0 0-.8.4l-1.9 2.533a1 1 0 0 1-1.6 0L5.3 12.4a1 1 0 0 0-.8-.4H2a2 2 0 0 1-2-2V2zm3.5 1a.5.5 0 0 0 0 1h9a.5.5 0 0 0 0-1h-9zm0 2.5a.5.5 0 0 0 0 1h9a.5.5 0 0 0 0-1h-9zm0 2.5a.5.5 0 0 0 0 1h5a.5.5 0 0 0 0-1h-5z"/>
            </svg>
          </div>
        </div>
        <div class="flex-grow-1">
          <p class="mensaje-text mb-0">{{ msg }}</p>
        </div>
      </div>
      <div class="card-footer text-end">
        <button class="btn btn-primary" @click="aceptar">Aceptar</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'MensajePage',
  data() {
    return {
      tipo: '',
      msg: '',
      icono: '',
      loading: false,
      error: ''
    };
  },
  created() {
    // Se espera recibir los parámetros por querystring o props
    // Ejemplo de ruta: /mensaje?tipo=Error&msg=Ocurri%C3%B3%20un%20error&icono=alto
    this.tipo = this.$route.query.tipo || 'Mensaje del Sistema';
    this.msg = this.$route.query.msg || '';
    this.icono = this.$route.query.icono || 'informacion';
    this.enviarMensaje();
  },
  methods: {
    async enviarMensaje() {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.show_message',
          payload: {
            tipo: this.tipo,
            msg: this.msg,
            icono: this.icono
          }
        });
        if (res.data.status !== 'success') {
          this.error = res.data.message || 'Error al mostrar el mensaje.';
        }
      } catch (error) {
        this.error = 'Error de comunicación con el servidor.';
      } finally {
        this.loading = false;
      }
    },
    aceptar() {
      // Cerrar mensaje o navegar a la página anterior
      if (this.$router && this.$router.history && this.$router.history.length > 1) {
        this.$router.back();
      } else {
        this.$router.push('/');
      }
    }
  }
};
</script>

<style scoped>
.mensaje-page {
  padding-top: 40px;
}

.icon-container {
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  width: 64px;
  height: 64px;
  background-color: rgba(var(--bs-secondary-rgb), 0.1);
}
.mensaje-text {
  font-size: 1.2rem;
  font-weight: bold;
  word-break: break-word;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}
</style>
