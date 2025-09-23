<template>
  <div class="semaforo-page">
    <h1>Formulario Semáforo</h1>
    <div class="semaforo-container">
      <div class="semaforo-shapes">
        <div :class="['semaforo-circle', {active: colorActual === 'ROJO'}]" style="background:red;"></div>
        <div :class="['semaforo-circle', {active: colorActual === 'VERDE'}]" style="background:green;"></div>
      </div>
      <div class="semaforo-controls">
        <button :disabled="enProceso" @click="iniciarSemaforo" class="btn btn-primary">
          {{ botonTexto }}
        </button>
        <div v-if="resultado">
          <p>Color: <b>{{ resultado.color }}</b> (numcolor: {{ resultado.numcolor }})</p>
        </div>
        <div class="semaforo-stats">
          <p>Rojos: {{ stats.rojos }}</p>
          <p>Verdes: {{ stats.verdes }}</p>
        </div>
      </div>
    </div>
    <div class="semaforo-footer">
      <button class="btn btn-success" :disabled="!resultado" @click="aceptarResultado">Aceptar</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SemaforoPage',
  data() {
    return {
      colorActual: null,
      resultado: null,
      stats: { rojos: 0, verdes: 0 },
      enProceso: false,
      botonTexto: 'Iniciar',
      tramiteId: null, // Debe ser seteado desde la navegación o props
      userId: 1 // Simulación de usuario
    };
  },
  created() {
    this.cargarStats();
  },
  methods: {
    async iniciarSemaforo() {
      this.enProceso = true;
      this.botonTexto = 'Procesando...';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.getRandomColor',
          payload: { user_id: this.userId }
        });
        if (res.data.status === 'success') {
          this.resultado = res.data.eResponse.data.result;
          this.colorActual = this.resultado.color;
          this.botonTexto = 'Aceptar';
        } else {
          alert(res.data.message || 'Error');
          this.botonTexto = 'Iniciar';
        }
      } catch (error) {
        alert('Error de conexión');
        this.botonTexto = 'Iniciar';
      }
      this.enProceso = false;
    },
    async aceptarResultado() {
      if (!this.resultado) return;
      // Simulación: tramiteId debe venir de la navegación real
      const tramiteId = this.tramiteId || 1;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.registerColorResult',
          payload: {
            tramite_id: tramiteId,
            color: this.resultado.color,
            user_id: this.userId
          }
        });
        if (res.data.status === 'success') {
          alert('Resultado registrado: ' + this.resultado.color);
          this.cargarStats();
          this.resultado = null;
          this.colorActual = null;
          this.botonTexto = 'Iniciar';
        } else {
          alert(res.data.message || 'Error');
        }
      } catch (error) {
        alert('Error de conexión');
      }
    },
    async cargarStats() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.getStats',
          payload: { user_id: this.userId }
        });
        if (res.data.status === 'success') {
          this.stats = res.data.eResponse.data.result;
        }
      } catch (error) {
        // Handle error silently for stats loading
      }
    }
  }
};
</script>

<style scoped>
.semaforo-page {
  max-width: 500px;
  margin: 40px auto;
  background: #f8f8f8;
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 2px 8px #0001;
}
.semaforo-container {
  display: flex;
  flex-direction: row;
  align-items: flex-start;
  gap: 32px;
}
.semaforo-shapes {
  display: flex;
  flex-direction: column;
  gap: 24px;
  margin-top: 24px;
}
.semaforo-circle {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  opacity: 0.3;
  border: 2px solid #333;
  transition: opacity 0.3s;
}
.semaforo-circle.active {
  opacity: 1;
  box-shadow: 0 0 16px 4px #3333;
}
.semaforo-controls {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.semaforo-footer {
  margin-top: 32px;
  text-align: right;
}
.btn {
  padding: 12px 24px;
  border-radius: 4px;
  border: none;
  font-size: 18px;
  cursor: pointer;
}
.btn-primary {
  background: #007bff;
  color: #fff;
}
.btn-success {
  background: #28a745;
  color: #fff;
}
</style>
