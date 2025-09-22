<template>
  <div class="pagalic-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Marcar Licencias/Anuncios como Pagados</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        Marcar licencias y anuncios como pagados
      </div>
      <div class="card-body">
        <form @submit.prevent="buscar">
          <div class="row mb-3">
            <div class="col-md-3">
              <label class="form-label fw-bold">Tipo</label>
              <div>
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="radio" id="tipoLicencia" value="licencia" v-model="tipo">
                  <label class="form-check-label" for="tipoLicencia">Licencia</label>
                </div>
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="radio" id="tipoAnuncio" value="anuncio" v-model="tipo">
                  <label class="form-check-label" for="tipoAnuncio">Anuncio</label>
                </div>
              </div>
            </div>
            <div class="col-md-3">
              <label class="form-label fw-bold">Número</label>
              <input type="number" class="form-control" v-model.number="numero" @keyup.enter="focusAxo" required>
            </div>
            <div class="col-md-3">
              <label class="form-label fw-bold">Año</label>
              <input type="number" class="form-control" v-model.number="axo" ref="axoInput" @keyup.enter="buscar" required>
            </div>
            <div class="col-md-3 d-flex align-items-end">
              <button type="submit" class="btn btn-success w-100">Buscar</button>
            </div>
          </div>
        </form>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="info" class="alert alert-info">{{ info }}</div>
        <div v-if="registro">
          <div class="row mb-2">
            <div class="col-md-4">
              <label class="fw-bold">Ubicación:</label>
              <span>{{ registro.ubicacion }}</span>
            </div>
            <div class="col-md-4">
              <label class="fw-bold">Num. Ext.:</label>
              <span>{{ registro.numext_ubic }}</span>
            </div>
            <div class="col-md-4">
              <label class="fw-bold">{{ tipo === 'licencia' ? 'Actividad' : 'Medidas' }}:</label>
              <span>{{ registro.actividad }}</span>
            </div>
          </div>
          <div v-if="adeudos && adeudos.length">
            <table class="table table-bordered table-sm">
              <thead class="table-light">
                <tr>
                  <th>Año</th>
                  <th>Forma</th>
                  <th>Derechos</th>
                  <th>Recargos</th>
                  <th>Saldo</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in adeudos" :key="row.id_licencia + '-' + row.axo + '-' + row.id_anuncio">
                  <td>{{ row.axo }}</td>
                  <td class="text-end">{{ row.forma }}</td>
                  <td class="text-end">{{ row.derechos }}</td>
                  <td class="text-end">{{ row.recargos }}</td>
                  <td class="text-end">{{ row.saldo }}</td>
                </tr>
              </tbody>
            </table>
            <button class="btn btn-primary" :disabled="marcando" @click="marcarPagado">Marcar como Pagado</button>
          </div>
        </div>
        <div v-if="success" class="alert alert-success mt-3">{{ success }}</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PagalicFrm',
  data() {
    return {
      tipo: 'licencia',
      numero: '',
      axo: '',
      registro: null,
      adeudos: [],
      error: '',
      info: '',
      success: '',
      marcando: false
    };
  },
  methods: {
    focusAxo() {
      this.$refs.axoInput && this.$refs.axoInput.focus();
    },
    async buscar() {
      this.error = '';
      this.info = '';
      this.success = '';
      this.registro = null;
      this.adeudos = [];
      if (!this.numero || !this.axo) {
        this.error = 'Debe ingresar número y año.';
        return;
      }
      let action = this.tipo === 'licencia' ? 'buscar_licencia' : 'buscar_anuncio';
      try {
        let res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action,
            params: {
              numero: this.numero,
              axo: this.axo
            }
          })
        });
        let data = await res.json();
        if (!data.success) {
          this.error = data.message || 'No se encontraron resultados.';
          return;
        }
        if (this.tipo === 'licencia') {
          this.registro = data.data.licencia;
        } else {
          this.registro = data.data.anuncio;
        }
        this.adeudos = data.data.adeudos;
        if (!this.adeudos.length) {
          this.info = 'No existen adeudos para esta Licencia/Anuncio.';
        }
      } catch (e) {
        this.error = 'Error de comunicación con el servidor.';
      }
    },
    async marcarPagado() {
      this.error = '';
      this.success = '';
      this.marcando = true;
      try {
        let res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'marcar_pagado',
            params: {
              tipo: this.tipo,
              numero: this.numero,
              axo: this.axo
            }
          })
        });
        let data = await res.json();
        if (!data.success) {
          this.error = data.message || 'No se pudo marcar como pagado.';
        } else {
          this.success = data.message;
          this.registro = null;
          this.adeudos = [];
        }
      } catch (e) {
        this.error = 'Error de comunicación con el servidor.';
      }
      this.marcando = false;
    }
  }
};
</script>

<style scoped>
.pagalic-page {
  max-width: 900px;
  margin: 0 auto;
}
</style>
