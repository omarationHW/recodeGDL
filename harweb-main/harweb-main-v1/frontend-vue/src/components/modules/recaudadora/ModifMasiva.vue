<template>
  <div class="modif-masiva-page">
    <h1>Modificación Masiva de Requerimientos</h1>
    <form @submit.prevent="onSubmit">
      <div class="form-row">
        <label>Tipo de Requerimiento:</label>
        <select v-model="tipo" required>
          <option value="predial">Predial</option>
          <option value="multa">Multa</option>
          <option value="licencia">Licencia</option>
          <option value="anuncio">Anuncio</option>
        </select>
      </div>
      <div class="form-row">
        <label>Recaudadora:</label>
        <input v-model="form.recaud" type="number" min="1" required />
      </div>
      <div class="form-row">
        <label>Folio Inicial:</label>
        <input v-model="form.folio_ini" type="number" min="1" required />
      </div>
      <div class="form-row">
        <label>Folio Final:</label>
        <input v-model="form.folio_fin" type="number" min="1" required />
      </div>
      <div class="form-row">
        <label>Fecha de Práctica:</label>
        <input v-model="form.fecha" type="date" required />
      </div>
      <div class="form-row">
        <label>Acción:</label>
        <select v-model="accion" required>
          <option value="modificar">Marcar como Practicado/Citado</option>
          <option value="cancelar">Cancelar Requerimientos</option>
        </select>
      </div>
      <div class="form-row">
        <label>Usuario:</label>
        <input v-model="form.user" type="text" required />
      </div>
      <div class="form-row">
        <button type="submit">Ejecutar</button>
      </div>
    </form>
    <div v-if="loading" class="loading">Procesando...</div>
    <div v-if="response" class="response">
      <h3>Resultado</h3>
      <pre>{{ response }}</pre>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ModifMasivaPage',
  data() {
    return {
      tipo: 'predial',
      accion: 'modificar',
      form: {
        recaud: '',
        folio_ini: '',
        folio_fin: '',
        fecha: '',
        user: ''
      },
      loading: false,
      response: null
    }
  },
  methods: {
    async onSubmit() {
      this.loading = true;
      this.response = null;
      let actionKey = '';
      if (this.tipo === 'predial' && this.accion === 'modificar') actionKey = 'modificar_predial';
      if (this.tipo === 'predial' && this.accion === 'cancelar') actionKey = 'cancelar_predial';
      if (this.tipo === 'multa' && this.accion === 'modificar') actionKey = 'modificar_multa';
      if (this.tipo === 'multa' && this.accion === 'cancelar') actionKey = 'cancelar_multa';
      if (this.tipo === 'licencia' && this.accion === 'modificar') actionKey = 'modificar_licencia';
      if (this.tipo === 'licencia' && this.accion === 'cancelar') actionKey = 'cancelar_licencia';
      if (this.tipo === 'anuncio' && this.accion === 'modificar') actionKey = 'modificar_anuncio';
      if (this.tipo === 'anuncio' && this.accion === 'cancelar') actionKey = 'cancelar_anuncio';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            action: actionKey,
            params: {
              recaud: this.form.recaud,
              folio_ini: this.form.folio_ini,
              folio_fin: this.form.folio_fin,
              fecha: this.form.fecha
            },
            user: this.form.user
          })
        });
        const data = await res.json();
        this.response = JSON.stringify(data, null, 2);
      } catch (e) {
        this.response = 'Error: ' + e.message;
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style scoped>
.modif-masiva-page {
  max-width: 600px;
  margin: 0 auto;
  padding: 2rem;
  background: #f9f9f9;
  border-radius: 8px;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  flex-direction: column;
}
label {
  font-weight: bold;
  margin-bottom: 0.3rem;
}
input, select {
  padding: 0.4rem;
  border: 1px solid #ccc;
  border-radius: 4px;
}
button {
  padding: 0.6rem 1.2rem;
  background: #007bff;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
button:hover {
  background: #0056b3;
}
.loading {
  color: #007bff;
  font-weight: bold;
}
.response {
  margin-top: 2rem;
  background: #fff;
  border: 1px solid #eee;
  padding: 1rem;
  border-radius: 6px;
}
</style>
